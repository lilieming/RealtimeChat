//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AppDelegate.h"
#import "ChatsView.h"
#import "CallsView.h"
#import "PeopleView.h"
#import "SettingsView.h"
#import "NavigationController.h"

#import "CallAudioView.h"
#import "CallVideoView.h"

@implementation AppDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Firebase initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FIRApp configure];
	[FIRDatabase database].persistenceEnabled = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Crashlytics initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Fabric with:@[[Crashlytics class]]];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Dialogflow initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ApiAI *apiAI = [ApiAI sharedApiAI];
	id <AIConfiguration> configuration = [[AIDefaultConfiguration alloc] init];
	configuration.clientAccessToken = DIALOGFLOW_ACCESS_TOKEN;
	apiAI.configuration = configuration;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Google login initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Facebook login initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Push notification initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge;
	UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
	[userNotificationCenter requestAuthorizationWithOptions:authorizationOptions completionHandler:^(BOOL granted, NSError *error)
	{
		if (error == nil)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[[UIApplication sharedApplication] registerForRemoteNotifications];
			});
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// OneSignal initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal initWithLaunchOptions:launchOptions appId:ONESIGNAL_APPID handleNotificationReceived:nil handleNotificationAction:nil
							settings:@{kOSSettingsKeyInAppAlerts:@NO}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal setLogLevel:ONE_S_LL_NONE visualLevel:ONE_S_LL_NONE];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// This can be removed once Firebase auth issue is resolved
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UserDefaults boolForKey:@"Initialized"] == NO)
	{
		[UserDefaults setObject:@YES forKey:@"Initialized"];
		[FUser logOut];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Shortcut items initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Shortcut create];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Connection, Location initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Connection shared];
	[Location shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// RelayManager initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[RelayManager shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Realm initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[Blockeds shared];
	[Blockers shared];
	[CallHistories shared];
	[Friends shared];
	[Groups shared];
	[LinkedIds shared];
	[LinkedUsers shared];
	[Messages shared];
	[Statuses shared];
	[UserStatuses shared];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// UI initialization
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	self.chatsView = [[ChatsView alloc] initWithNibName:@"ChatsView" bundle:nil];
	self.callsView = [[CallsView alloc] initWithNibName:@"CallsView" bundle:nil];
	self.peopleView = [[PeopleView alloc] initWithNibName:@"PeopleView" bundle:nil];
	self.groupsView = [[GroupsView alloc] initWithNibName:@"GroupsView" bundle:nil];
	self.settingsView = [[SettingsView alloc] initWithNibName:@"SettingsView" bundle:nil];

	NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.chatsView];
	NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.callsView];
	NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.peopleView];
	NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.groupsView];
	NavigationController *navController5 = [[NavigationController alloc] initWithRootViewController:self.settingsView];

	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = @[navController1, navController2, navController3, navController4, navController5];
	self.tabBarController.tabBar.translucent = NO;
	self.tabBarController.selectedIndex = DEFAULT_TAB;

	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.chatsView view];
	[self.callsView view];
	[self.peopleView view];
	[self.groupsView view];
	[self.settingsView view];
	//---------------------------------------------------------------------------------------------------------------------------------------------


	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Location stop];
	UpdateLastTerminate(YES);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Location start];
	UpdateLastActive();
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[FBSDKAppEvents activateApp];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[OneSignal IdsAvailable:^(NSString *userId, NSString *pushToken)
	{
		if (pushToken != nil)
			[UserDefaults setObject:userId forKey:ONESIGNALID];
		else [UserDefaults removeObjectForKey:ONESIGNALID];
		UpdateOneSignalId();
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[CacheManager cleanupExpired];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[NotificationCenter post:NOTIFICATION_APP_STARTED];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - CoreSpotlight methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return NO;
}


#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeUnknown];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([[FIRAuth auth] canHandleNotification:notification])
	{
		completionHandler(UIBackgroundFetchResultNoData);
		return;
	}
}

#pragma mark - Home screen dynamic quick action methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

@end
