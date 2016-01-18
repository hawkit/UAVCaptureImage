#import "RequiredAppUIKit.h"
#import "RequiredAVFoundation.h"

#if TARGET_OS_IPHONE

#import "AVCaptureImageController.h"

@interface AVCaptureUIViewController : UIViewController<AVCaptureImageControllerDelegate>
{
}

@property (ARC_PROP_OUTLET) IBOutlet AVCaptureImageController* outletCaptureImageController;

@end

#endif /* TARGET_OS_IPHONE */
