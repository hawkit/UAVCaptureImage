#import "AVCaptureImageControllerBase.h"
#import "AVCaptureImageControllerIOS.h"
#import "AVCaptureImageControllerOSX.h"

#if TARGET_OS_IPHONE

@interface  AVCaptureImageController : AVCaptureImageControllerIOS
@end

#else /* !TARGET_OS_IPHONE */

@interface  AVCaptureImageController : AVCaptureImageControllerOSX
@end

#endif /* TARGET_OS_IPHONE */
