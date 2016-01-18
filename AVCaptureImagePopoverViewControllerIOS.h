#import "RequiredAppUIKit.h"

#import "AVCaptureImageModel.h"
#import "AVCaptureImageController.h"

#if TARGET_OS_IPHONE

@interface AVCaptureImagePopoverViewControllerIOS : UIViewController

-(IBAction) actionSnapImageAndDismissController:(id)sender;

@end

#endif /* TARGET_OS_IPHONE */
