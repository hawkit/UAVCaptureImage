#import "QTKitCaptureImagePopoverViewControllerOSX.h"
#import "CMCaptureImageModelCIImage.h"

#if !TARGET_OS_IPHONE

@implementation QTKitCaptureImagePopoverViewControllerOSX

- (void) dealloc {
	ARC_SUPERDEALLOC(self);
}

@end

#endif /* TARGET_OS_IPHONE */
