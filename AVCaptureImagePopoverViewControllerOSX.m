#import "AVCaptureImagePopoverViewControllerOSX.h"

#if !TARGET_OS_IPHONE

@implementation AVCaptureImagePopoverViewControllerOSX

@dynamic outletCaptureStillImage;
@dynamic outletCaptureVideoImage;

- (void) dealloc {
	ARC_SUPERDEALLOC(self);
}

@end

#endif /* TARGET_OS_IPHONE */
