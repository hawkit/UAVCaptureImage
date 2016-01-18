#import "AVCaptureImageControllerBase.h"

#if !TARGET_OS_IPHONE

@interface AVCaptureImageControllerOSX : AVCaptureImageControllerBase
{
}

- (void)captureSetup;
- (void)captureSetupSessionOutputForVideoCapture:(AVCaptureSession*)session;
- (void)captureTeardown;

-(void) captureWriteImageData:(NSData*)imageData imageMetadata:(id)imageMetadata;

@end

#endif /* !TARGET_OS_IPHONE */