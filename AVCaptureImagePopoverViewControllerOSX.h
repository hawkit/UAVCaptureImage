#import "RequiredAppUIKit.h"

#import "AVCaptureImageModel.h"
#import "AVCaptureImageController.h"
#import "CMCaptureImagePopoverViewControllerOSX.h"

#if !TARGET_OS_IPHONE

@interface AVCaptureImagePopoverViewControllerOSX : CMCaptureImagePopoverViewControllerOSX

ARC_BEGIN_IVAR_DECL(AVCaptureImagePopoverViewControllerOSX)
ARC_END_IVAR_DECL(AVCaptureImagePopoverViewControllerOSX)

@property (ARC_PROP_OUTLET) IBOutlet AVCaptureImageModel* outletCaptureStillImage;
@property (ARC_PROP_OUTLET) IBOutlet AVCaptureImageModel* outletCaptureVideoImage;

@end

#endif /* !TARGET_OS_IPHONE */