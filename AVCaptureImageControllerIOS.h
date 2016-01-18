#import "AVCaptureImageControllerBase.h"

#if TARGET_OS_IPHONE

@interface AVCaptureImageControllerIOS : AVCaptureImageControllerBase

ARC_BEGIN_IVAR_DECL(AVCaptureImageControllerIOS)
ARC_IVAR_DECLARE(UIView*,flashView,__flashView);
ARC_IVAR_DECLARE(CGFloat,beginGestureScale,__beginGestureScale);
ARC_END_IVAR_DECL(AVCaptureImageControllerIOS)

- (void)captureSetup;
- (BOOL)captureSetupPreviewUI;
- (void)captureTeardown;
- (AVCaptureVideoOrientation)captureOrientationForDeviceOrientation;

- (void)captureWriteImageData:(NSData*)imageData imageMetadata:(id)imageMetadata;
- (void)captureFlashViewAnimationForCapturingStillImage:(BOOL)capturingStillImage;

@end

#endif /* TARGET_OS_IPHONE */