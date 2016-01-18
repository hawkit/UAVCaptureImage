#import "RequiredAppUIKit.h"

#if TARGET_OS_IPHONE

@interface UIApplication (Utilities)

+(BOOL) versionNineOS;
+(UIWindow*) rootWindow;
+(CGRect) rootWindowFrame;

@end

#endif /* TARGET_OS_IPHONE */
