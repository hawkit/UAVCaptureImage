#import "UIApplication+Utilities.h"

#if TARGET_OS_IPHONE

@implementation UIApplication (Utilities)

+(BOOL) versionNineOS
{
NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
	return (osVersion.majorVersion>=9);
}

+(UIWindow*) rootWindow
{
UIWindow* window = [[[self sharedApplication] windows] firstObject];
	NSLog(@"screenHeight=%f width=%f",window.frame.size.height,window.frame.size.width);
	return window;
}

+(CGRect) rootWindowFrame
{
	return [self rootWindow].frame;
}

@end

#endif /* TARGET_OS_IPHONE */
