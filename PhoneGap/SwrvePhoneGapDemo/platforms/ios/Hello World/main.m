#import <UIKit/UIKit.h>

#define TESTING [[NSUserDefaults standardUserDefaults] boolForKey:@"TESTING"]

int main(int argc, char* argv[])
{
    @autoreleasepool {
        NSString* appDelegateClassName = (TESTING)? @"TestAppDelegate" : @"AppDelegate";
        int retVal = UIApplicationMain(argc, argv, nil, appDelegateClassName);
        return retVal;
    }
}
