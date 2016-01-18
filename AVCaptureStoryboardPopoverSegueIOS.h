#import "RequiredAppUIKit.h"

#if TARGET_OS_IPHONE

@interface AVCaptureStoryboardPopoverSegueIOS : UIStoryboardSegue
+(CGSize) preferredContentSize;
@end

#endif /* TARGET_OS_IPHONE */
