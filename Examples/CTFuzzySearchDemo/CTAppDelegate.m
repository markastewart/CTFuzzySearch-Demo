#import "CTAppDelegate.h"

#import "CTEditViewController.h"

@implementation CTAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UINavigationController *nc = [UINavigationController new];
    [nc pushViewController:[CTEditViewController new] animated:NO];
    self.window.rootViewController = nc;    
    [self.window makeKeyAndVisible];    
    return YES;
}

@end
