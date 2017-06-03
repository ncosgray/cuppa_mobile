#include "AppDelegate.h"
#import <Flutter/Flutter.h>
#include "GeneratedPluginRegistrant.h"
@import UserNotifications;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  FlutterViewController *flutterController =
      (FlutterViewController *)self.window.rootViewController;

  // iOS platform: set up Flutter channels
  FlutterMethodChannel* notificationChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.nathanatos.Cuppa/notification"
                                            binaryMessenger:flutterController];
  [notificationChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([@"setupNotification" isEqualToString:call.method]) {
          NSString* secsVal = call.arguments;
          [self sendNotification:[secsVal intValue]];
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
						  
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// iOS platform: handle send notification
- (void)sendNotification:(int)secs {
    // Set up notification content
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Brewing complete";
    content.body = @"Your tea is now ready!";
    content.sound = [UNNotificationSound defaultSound];
    [content setValue:@YES forKey:@"shouldAlwaysAlertWhileAppIsForeground"];
            
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

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  [super applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  [super applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  [super applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  [super applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  [super applicationWillTerminate:application];
}

- (BOOL)application:(UIApplication*)application
            openURL:(NSURL*)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation {
  // Called when the application is asked to open a resource specified by a URL.
  return [super application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
@end
