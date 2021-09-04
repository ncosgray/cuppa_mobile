#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
@import UserNotifications;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    FlutterViewController* flutterController = (FlutterViewController*)self.window.rootViewController;
    
    // iOS platform: set up Flutter channels
    FlutterMethodChannel* notificationChannel = [FlutterMethodChannel
                                                 methodChannelWithName:@"com.nathanatos.Cuppa/notification"
                                                 binaryMessenger:flutterController];
    [notificationChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"setupNotification" isEqualToString:call.method]) {
            int secsVal = [call.arguments[@"secs"] intValue];
            NSString* titleVal = call.arguments[@"title"];
            NSString* textVal = call.arguments[@"text"];
            [self sendNotification: secsVal :titleVal :textVal];
        }
        else if ([@"cancelNotification" isEqualToString:call.method]) {
            [self cancelNotification];
        }
        else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    // Get authorization from user to send local notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error while getting authorization to send notifications");
        }
    }];
    
    // Set up delegate to receive notification while app is in foreground
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// iOS platform: handle send notification
- (void)sendNotification:(int)secs :(NSString*)title :(NSString*)text {
    // Set up notification content
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = title;
    content.body = text;
    content.sound = [UNNotificationSound soundNamed:@"sound/spoon.aiff"];
    
    // Configure the notification schedule
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:secs
                                                                                                    repeats:NO];
    
    // Create the request
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    NSString *identifier = @"CuppaAlarm";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error while creating notification request");
        }
    }];
}

// iOS platform: handle cancel notification
- (void)cancelNotification {
    // Remove our notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
}

// iOS platform: handle notification while app is in foreground
- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

@end
