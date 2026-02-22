#!/bin/bash

################################################################################
# Screenshot Automation Script
################################################################################
#
# OVERVIEW:
#   This script automates the collection of localized screenshots from Flutter
#   integration tests on both Android emulators (AVDs) and iOS simulators. For
#   each device and locale combination, it:
#     1. Boots the device
#     2. Applies the specified locale
#     3. Runs Flutter integration tests
#     4. Automatically renames generated screenshots according to device-specific
#        naming patterns
#     5. Processes images to remove alpha channel for app store compliance
#
# PREREQUISITES:
#   - Flutter SDK installed and in PATH
#   - Android SDK with emulator tools in PATH (for Android tests)
#   - Xcode command line tools with simctl in PATH (for iOS tests)
#   - jq (JSON query tool) installed for parsing simctl output
#   - ImageMagick `magick` command installed for image processing
#   - A working Flutter app with an integration test file at the TEST_NAME path
#   - Integration test driver that saves screenshots into SCREENSHOT_DIR
#
# USAGE:
#   ./run_screenhots.sh
#
# CONFIGURATION:
#   Edit the sections below to customize:
#   - APP_ID: Your Flutter app's package identifier
#   - LOCALES: Locales to test (e.g., "en-US", "de-DE", "zh-Hans")
#   - DEVICE_ENTRIES: Device names, types, and filename patterns
#   - TEST_NAME: Path to the Flutter integration test file
#   - TEST_DRIVER_NAME: Path to the Flutter integration test driver
#   - SCREENSHOT_DIR: Output directory for screenshots
#
# OUTPUT:
#   Screenshots are organized into subdirectories by locale under SCREENSHOT_DIR.
#   Filenames follow the pattern defined per device using {NUM} and {LOCALE}
#   placeholders.
#
# NOTES:
#   - Device names must exactly match the emulator/simulator identifiers
#   - Screenshot numbering is 0-based and assigned alphabetically by filename
#   - Existing screenshots in SCREENSHOT_DIR are removed at script start
#   - Tests are retried up to 3 times with 5-second delays between attempts
#
################################################################################

## ============================================================================
## INTEGRATION TEST SETTINGS AND APP CONFIGURATION
## ============================================================================

## Package ID of the Flutter app being tested
APP_ID="com.nathanatos.Cuppa"

## Array of locales to test. The script will run tests for each locale on all
## configured devices.
LOCALES=("en-US")

## Name of the Flutter integration test file to execute (under integration_test/)
TEST_NAME="screenshots_test.dart"

## Name of the Flutter integration test driver (under integration_test/)
TEST_DRIVER_NAME="integration_test_driver.dart"

## Directory where screenshots will be collected and organized by locale
SCREENSHOT_DIR="screenshots-output"

## ============================================================================
## DEVICE CONFIGURATION
## ============================================================================

## Device entries compact configuration
##
## Format: Each entry is a colon-separated tuple:
##   <type>:<device-name>:<pattern>
##
## Where:
##   - type: "android" or "ios"
##   - device-name: Name/identifier for the device (must match exactly what
##                  the emulator or xcrun simctl will recognize)
##   - pattern: Filename pattern with optional {NUM} and {LOCALE} placeholders
##
## Pattern placeholders:
##   {NUM}    - Replaced with the screenshot number (0, 1, 2, ...)
##   {LOCALE} - Replaced with the locale being tested (e.g., "en-US")
##
## Numbering: Screenshots are numbered sequentially starting at 0 and assigned
## based on alphabetical order of the original filenames created by the test.
##
## Examples:
##   "screenshot_{NUM}.png"
##     Result: screenshot_0.png, screenshot_1.png, ...
##   "app_{NUM}_{LOCALE}.png"
##     Result: app_0_en-US.png, app_1_en-US.png, app_0_de-DE.png, etc.
##   "{NUM}_APP_IPAD_PRO_3GEN_129_{NUM}.png"
##     Result: 0_APP_IPAD_PRO_3GEN_129_0.png, 1_APP_IPAD_PRO_3GEN_129_1.png, ...
##
DEVICE_ENTRIES=(
    "ios:iPad Air 13-inch (M3):{NUM}_APP_IPAD_PRO_3GEN_129_{NUM}.png"
    "ios:iPhone 16 Plus:{NUM}_APP_IPHONE_16_PLUS_{NUM}.png"
    "android:Pixel_9_API_36:phone{NUM}_{LOCALE}.png"
    "android:Pixel_C_Tablet_API_33:tablet{NUM}_{LOCALE}.png"
)

## ============================================================================
## HELPER FUNCTIONS
## ============================================================================

## Function: get_pattern_for_device
## Purpose: Find the filename pattern for a device name from DEVICE_ENTRIES.
## Parameters:
##   $1 - device name (string) exactly as listed in DEVICE_ENTRIES entries.
## Returns:
##   Prints the matching pattern to stdout and returns 0 on success,
##   returns 1 if no matching entry is found.
get_pattern_for_device() {
    local key="$1"
    local entry
    for entry in "${DEVICE_ENTRIES[@]}"; do
        IFS=':' read -r dtype name pattern <<< "$entry"
        if [ "$name" = "$key" ]; then
            printf '%s' "$pattern"
            return 0
        fi
    done
    return 1
}

# Function: create_marker
# Purpose: Create a timestamp-like marker file that can be used to detect
#          screenshots produced after this point.
# Parameters:
#   $1 - device name (string) used to compose the marker filename
#   $2 - locale (string) used to create the device-specific screenshots
# Returns:
#   Prints the created marker filepath to stdout.
create_marker() {
    local device="$1"
    local locale="$2"
    mkdir -p "$SCREENSHOT_DIR/$locale"
    local marker="$SCREENSHOT_DIR/.marker_${device// /_}_$locale_$$"
    touch "$marker"
    printf '%s' "$marker"
}

## Function: rename_new_screenshots
## Purpose: Rename screenshots created after a given marker file according to
##          the device-specific filename pattern. Files are sorted
##          alphabetically and assigned sequential numbers starting at 0.
## Parameters:
##   $1 - device key/name (string) used to look up the pattern
##   $2 - locale (string) used to substitute {LOCALE} in patterns
##   $3 - marker_file (path) used as the 'newer than' reference for find
## Returns:
##   0 on success, non-zero on error.
rename_new_screenshots() {
    local device_key="$1"
    local locale="$2"
    local marker_file="$3"

    local pattern
    pattern=$(get_pattern_for_device "$device_key")
    if [ -z "$pattern" ]; then
        echo "No filename pattern configured for device: $device_key. Skipping rename."
        return 0
    fi

    local dir="$SCREENSHOT_DIR/$locale"
    [ -d "$dir" ] || { echo "Screenshot dir $dir does not exist."; return 0; }

    # Find files newer than marker, sort alphabetically, assign numbers 0..N
    new_files=()
    while IFS= read -r f; do
        new_files+=("$f")
    done < <(find "$dir" -type f -name '*.png' -newer "$marker_file" -print | sort)
    if [ ${#new_files[@]} -eq 0 ]; then
        echo "No new screenshots found for $device_key $locale."
        return 0
    fi

    local idx=0
    for src in "${new_files[@]}"; do
        # Compute target name by replacing {NUM} with the index,
        # and replacing {LOCALE} with the locale string.
        local base_pattern="$pattern"
        local target_name="${base_pattern//\{NUM\}/$idx}"
        target_name="${target_name//\{LOCALE\}/$locale}"

        local dst="$dir/$target_name"
        # If destination exists, append a suffix to avoid clobbering
        if [ -e "$dst" ]; then
            local suffix=1
            while [ -e "${dst%.*}_$suffix.${dst##*.}" ]; do
                suffix=$((suffix + 1))
            done
            dst="${dst%.*}_$suffix.${dst##*.}"
        fi

        echo "Renaming: $(basename "$src") -> $(basename "$dst")"
        mv "$src" "$dst"
        idx=$((idx + 1))
    done

    # Remove the marker file
    rm -f "$marker_file"
}

## Function: run_with_retries
## Purpose: Run a provided command with retries on failure.
## Parameters:
##   $1 - attempts (integer) number of attempts
##   $2 - delay (seconds) between attempts
##   $3... - the command and its arguments to execute
## Returns:
##   0 if the command eventually succeeds, otherwise returns the
##   last command's exit code.
run_with_retries() {
    local attempts="$1"; shift
    local delay="$1"; shift
    local cmd=("$@")
    local try=1
    local exit_code=0

    while [ $try -le $attempts ]; do
        echo "Attempt $try/$attempts: ${cmd[*]}"
        "${cmd[@]}"
        exit_code=$?
        if [ $exit_code -eq 0 ]; then
            return 0
        fi
        echo "Command failed with exit code $exit_code."
        if [ $try -lt $attempts ]; then
            echo "Retrying in ${delay}s..."
            sleep $delay
        fi
        try=$((try + 1))
    done

    echo "Command failed after ${attempts} attempts."
    return $exit_code
}

## Function: run_tests_on_avd
## Purpose: Boot an Android AVD, set locale, run Flutter integration tests,
##          and rename any screenshots produced by the run.
## Parameters:
##   $1 - AVD name (string) as shown to the emulator command
##   $2 - locale (string) to apply to the device for the test run
## Returns:
##   0 on success, non-zero if any high-level steps fail.
run_tests_on_avd() {
    local AVD_NAME="$1"
    local LOCALE="$2"
    
    echo "--- Starting screenshots on AVD: $AVD_NAME for locale: $LOCALE ---"
    
    # Kill any existing emulator instance to start fresh
    echo "Stopping any running emulators..."
    adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done

    # Start the emulator in the background, suppressing GUI
    echo "Starting emulator for $AVD_NAME..."
    emulator -avd "$AVD_NAME" -no-snapshot-load -no-snapshot-save -no-window > /dev/null 2>&1 &

    # Wait for the emulator to fully boot
    echo "Waiting for emulator to finish booting..."
    adb wait-for-device shell 'while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done'
    adb shell input keyevent 82 # Unlock the screen

    # Set device locale properties
    echo "Applying locale $LOCALE and then rebooting..."
    adb shell "content insert --uri content://settings/system --bind name:s:system_locales --bind value:s:$LOCALE"
    adb shell "settings put System system_locales $LOCALE"
    adb shell "am broadcast -a com.android.intent.action.LOCALE_CHANGED --es com.android.intent.extra.LOCALE $LOCALE"
    adb reboot
    adb wait-for-device shell 'while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done'
    adb shell input keyevent 82 # Unlock the screen

    # Confirm the device is ready
    echo "Emulator is ready. Running screenshots..."
    adb devices

    # Run Flutter integration tests (with retries on failure)
    export DEVICE_NAME="$AVD_NAME"
    export TEST_LOCALE="$LOCALE"
    adb uninstall $APP_ID
    sleep 5
    # Create a marker file so we can detect which screenshots were created by
    # this device run. The renamer will look for files newer than this marker.
    marker_file=$(create_marker "$AVD_NAME" "$LOCALE")

    run_with_retries 3 5 flutter drive --driver=integration_test/$TEST_DRIVER_NAME \
                  --target=integration_test/$TEST_NAME \
                  -d "sdk gphone64 arm64"

    # Rename any screenshots created by this run according to the pattern
    rename_new_screenshots "$AVD_NAME" "$LOCALE" "$marker_file"

    # Kill the emulator after tests are done
    echo "Screenshots complete. Shutting down emulator..."
    adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done

    sleep 5
    echo "--- Finished screenshots on AVD: $AVD_NAME for locale: $LOCALE ---"
}

## Function: run_tests_on_ios
## Purpose: Boot an iOS Simulator, set locale, run Flutter integration tests,
##          and rename any screenshots produced by the run.
## Parameters:
##   $1 - simulator name (string) as listed by `xcrun simctl list`
##   $2 - locale (string) to apply to the simulator for the test run
## Returns:
##   0 on success, non-zero if any high-level steps fail.
run_tests_on_ios() {
    local SIMULATOR_NAME="$1"
    local LOCALE="$2"
    local LANG_CODE=$(echo "$LOCALE" | cut -d'-' -f1)
    if [ ${#LOCALE} -gt 5 ]; then
        LANG_CODE="$LOCALE" # Override for locales like zh-Hans
    fi

    echo "--- Starting tests on iOS Simulator: $SIMULATOR_NAME for locale: $LOCALE ---"

    # Get the UDID for the specified simulator name
    local UDID=$(xcrun simctl list devices available --json | jq --raw-output '.devices | flatten | .[] | select(.name == "'"$SIMULATOR_NAME"'") | .udid')
    if [[ -z "$UDID" ]]; then
        echo "Error: Simulator named \"$SIMULATOR_NAME\" not found. Exiting."
        return 1
    fi

    # Shut down all other running simulators to ensure isolation
    echo "Shutting down all other simulators..."
    xcrun simctl shutdown all > /dev/null 2>&1

    # Boot the specific simulator
    echo "Booting simulator: $SIMULATOR_NAME with UDID $UDID..."
    xcrun simctl boot "$UDID" > /dev/null 2>&1

    # Wait for the simulator to be ready using bootstatus
    echo "Waiting for simulator to finish booting..."
    xcrun simctl bootstatus "$UDID" -b

    # Set device locale properties
    echo "Applying locale $LOCALE using defaults write..."
    xcrun simctl spawn "$UDID" defaults write "Apple Global Domain" AppleLanguages -array $LANG_CODE
    xcrun simctl spawn "$UDID" defaults write "Apple Global Domain" AppleLocale -string $LOCALE
    killall -HUP SpringBoard
    
    # Run Flutter integration tests (with retries on failure)
    echo "Simulator is ready. Running screenshots..."
    export DEVICE_NAME="$SIMULATOR_NAME"
    export TEST_LOCALE="$LOCALE"
    sleep 5

    # Create a marker file so we can detect which screenshots were created by
    # this simulator run. The renamer will look for files newer than this marker.
    marker_file=$(create_marker "$SIMULATOR_NAME" "$LOCALE")

    run_with_retries 3 5 flutter drive --driver=integration_test/$TEST_DRIVER_NAME \
                  --target=integration_test/$TEST_NAME \
                  -d "$UDID"

    # Rename any screenshots created by this run according to the pattern
    rename_new_screenshots "$SIMULATOR_NAME" "$LOCALE" "$marker_file"

    # Shut down the specific simulator after tests are done
    echo "Screenshots complete. Shutting down $SIMULATOR_NAME..."
    xcrun simctl shutdown "$UDID" > /dev/null 2>&1

    sleep 5
    echo "--- Finished screenshots on iOS Simulator: $SIMULATOR_NAME for locale: $LOCALE ---"
}

## ============================================================================
## MAIN EXECUTION: Generate screenshots for all devices and locales
## ============================================================================

# Cleanup the screenshots directory
rm -rf "$SCREENSHOT_DIR"

## For each locale, run tests on all configured devices in order (android first,
## then ios). Screenshots are renamed immediately after each device run before
## proceeding with the next device. After all devices have run for a given
## locale, image processing (alpha removal) is applied.
for LOCALE in "${LOCALES[@]}"; do
    for entry in "${DEVICE_ENTRIES[@]}"; do
        IFS=':' read -r dtype name pattern <<< "$entry"
        if [ "$dtype" = "android" ]; then
            run_tests_on_avd "$name" "$LOCALE"
        else
            run_tests_on_ios "$name" "$LOCALE"
        fi
    done

    # Remove alpha channel from all screenshots
    for IMG in "$SCREENSHOT_DIR"/"$LOCALE"/*.png; do
        [ -e "$IMG" ] || continue
        magick "$IMG" -background black -alpha remove -alpha off "$IMG"
        echo "Processed: $IMG"
    done
done

echo "All screenshots completed."