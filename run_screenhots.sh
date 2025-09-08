#!/bin/bash

# Integration test file name
TEST_NAME="screenshots_test.dart"

# Function to run screenshots on a specified Android AVD
run_tests_on_avd() {
    local AVD_NAME="$1"
    
    echo "--- Starting screenshots on AVD: $AVD_NAME ---"
    
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

    # Confirm the device is ready
    echo "Emulator is ready. Running screenshots..."
    adb devices

    # Run Flutter integration tests
    export DEVICE_NAME="$AVD_NAME"    
    flutter drive --driver=integration_test/integration_test_driver.dart \
                  --target=integration_test/$TEST_NAME \
                  -d "sdk gphone64 arm64"

    # Kill the emulator after tests are done
    echo "Screenshots complete. Shutting down emulator..."
    adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done

    echo "--- Finished screenshots on AVD: $AVD_NAME ---"
}

# Function to run screenshots on a specified iOS simulator
run_tests_on_ios() {
    local SIMULATOR_NAME="$1"
    
    echo "--- Starting tests on iOS Simulator: $SIMULATOR_NAME ---"

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
    
    # Run Flutter integration tests, targeting the specific simulator by UDID
    echo "Simulator is ready. Running screenshots..."
    export DEVICE_NAME="$SIMULATOR_NAME"
    flutter drive --driver=integration_test/integration_test_driver.dart \
                  --target=integration_test/$TEST_NAME \
                  -d "$UDID"

    # Shut down the specific simulator after tests are done
    echo "Screenshots complete. Shutting down $SIMULATOR_NAME..."
    xcrun simctl shutdown "$UDID" > /dev/null 2>&1

    echo "--- Finished screenshots on iOS Simulator: $SIMULATOR_NAME ---"
}

# Cleanup the screenshots directory
rm -rf screenshots-output

# Android screenshots
run_tests_on_avd "Pixel_9_API_36"
run_tests_on_avd "Pixel_C_Tablet_API_33"

# iOS screenshots
run_tests_on_ios "iPhone 16 Plus"
run_tests_on_ios "iPad Air 13-inch (M3)"

echo "All screenshots completed."