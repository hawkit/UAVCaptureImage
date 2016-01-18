#import "RequiredAppUIKit.h"

#import <QTKit/QTKit.h>

#import "CMCaptureImageModel.h"
#import "CMCaptureImageControllerBase.h"

@class QTKitCaptureImageControllerBase;
@protocol QTKitCaptureImageControllerDelegate<CMCaptureImageControllerDelegate>
@end

@interface QTKitCaptureImageControllerBase : CMCaptureImageControllerBase

ARC_BEGIN_IVAR_DECL(QTKitCaptureImageControllerBase)
ARC_IVAR_DECLARE(CVImageBufferRef,imageBufferRef,__imageBufferRef);
ARC_IVAR_DECLARE(QTCaptureSession*,captureSession,__captureSession);
ARC_IVAR_DECLARE(QTCaptureDeviceInput*,captureVideoDeviceInput,__captureVideoDeviceInput);
ARC_IVAR_DECLARE(QTCaptureDecompressedVideoOutput*,captureVideoOutput,__captureVideoOutput);
ARC_END_IVAR_DECL(QTKitCaptureImageControllerBase)

@property (ARC_PROP_OUTLET) IBOutlet id<QTKitCaptureImageControllerDelegate> delegate;
@property (ARC_PROP_OUTLET) IBOutlet QTCaptureView*					outletCapturePreviewView;

@property (ARC_PROP_STRONG,readonly) QTCaptureSession*				captureSession;
@property (ARC_PROP_STRONG,readonly) QTCaptureDeviceInput*			captureVideoDeviceInput;
@property (ARC_PROP_STRONG,readonly) QTCaptureDecompressedVideoOutput* captureVideoOutput;

- (void)captureSetup;
- (BOOL)captureSetupPreviewUI;
- (void)captureTeardown;

- (IBAction)actionCaptureSnapshot:(id)sender;
-(void) captureSnapStillPictureFromImageBuffer:(CVImageBufferRef)imageBuffer;

@end
