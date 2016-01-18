#import "RequiredAppUIKit.h"
#import "RequiredAVFoundation.h"

#import "CMCaptureImageModel.h"
#import "CMCaptureImageControllerBase.h"

@class AVCaptureImageControllerBase;
@protocol AVCaptureImageControllerDelegate<CMCaptureImageControllerDelegate>
@end

@interface AVCaptureImageControllerBase : CMCaptureImageControllerBase

ARC_BEGIN_IVAR_DECL(AVCaptureImageControllerBase)
ARC_IVAR_DECLARE(AVCaptureVideoPreviewLayer*,capturePreviewLayer,__capturePreviewLayer);
ARC_IVAR_DECLARE(AVCaptureStillImageOutput*,captureStillImageOutput,__captureStillImageOutput);
ARC_IVAR_DECLARE(AVCaptureVideoDataOutput*,captureVideoDataOutput,__captureVideoDataOutput);
@protected
ARC_IVAR_DECLARE(BOOL,captureIsUsingFrontFacingCamera,__captureIsUsingFrontFacingCamera);
ARC_IVAR_DECLARE(CGFloat,captureEffectiveScale,__captureEffectiveScale);
ARC_END_IVAR_DECL(AVCaptureImageControllerBase)

@property (ARC_PROP_OUTLET) IBOutlet id<AVCaptureImageControllerDelegate> delegate;

@property (readonly) NSString*		captureSessionPreset;
@property (readonly) NSDictionary*	captureStillImageOutputSettings;
@property (readonly) NSDictionary*	captureVideoCaptureOutputSettings;
@property (assign)	CGFloat			captureEffectiveScale;
@property (assign)	BOOL			captureIsUsingFrontFacingCamera;

@property (ARC_PROP_STRONG,readonly) AVCaptureVideoPreviewLayer*	capturePreviewLayer;
@property (ARC_PROP_STRONG,readonly) AVCaptureVideoDataOutput*		captureVideoDataOutput;
@property (ARC_PROP_STRONG,readonly) AVCaptureStillImageOutput*		captureStillImageOutput;
@property (ARC_PROP_STRONG,readonly) AVCaptureConnection*			captureVideoCaptureConnection;
@property (readonly,nonatomic)		AVCaptureVideoOrientation		captureOrientationForDeviceOrientation;
@property (readonly)				CALayer*						capturePreviewRootLayer;

- (void)captureSetup;
- (BOOL)captureSetupPreviewUI;
- (void)captureSetupSessionOutputForStillImageCapture:(AVCaptureSession*)session;
- (void)captureSetupSessionOutputForVideoCapture:(AVCaptureSession*)session;
- (void)captureTeardown;

- (IBAction)actionCaptureSnapshot:(id)sender;
- (IBAction)actionCaptureSwitchFrontAndBackCameras:(id)sender;

- (void)captureSnapStillPictureFromSampleBuffer:(CMSampleBufferRef)imageDataSampleBuffer;

@end
