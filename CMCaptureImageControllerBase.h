#import "RequiredAppUIKit.h"

#import "CMCaptureImageModel.h"

@class CMCaptureImageControllerBase;
@protocol CMCaptureImageControllerDelegate
@optional
- (void)captureController:(CMCaptureImageControllerBase*)controller outputCaptureImage:(CMCaptureImageModel*)image sampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)captureController:(CMCaptureImageControllerBase*)controller outputCaptureImage:(CMCaptureImageModel*)image imageBuffer:(CVImageBufferRef)imageBuffer;
@end

@interface CMCaptureImageControllerBase : NSObject

ARC_BEGIN_IVAR_DECL(CMCaptureImageControllerBase)
ARC_IVAR_DISPATCHQ(captureVideoQueue,__captureVideoQueue);
@public
ARC_IVAR_DECLAREOUTLET(id<CMCaptureImageControllerDelegate>,delegate);
ARC_IVAR_DECLAREOUTLET(CMCaptureImageModel*,outletCaptureStillModel);
ARC_IVAR_DECLAREOUTLET(CMCaptureImageModel*,outletCaptureVideoModel);
ARC_IVAR_DECLAREOUTLET(id,outletCapturePreviewView);
ARC_END_IVAR_DECL(CMCaptureImageControllerBase)

@property (ARC_PROP_OUTLET) IBOutlet id<CMCaptureImageControllerDelegate> delegate;
@property (ARC_PROP_OUTLET) IBOutlet CMCaptureImageModel*	outletCaptureStillModel;
@property (ARC_PROP_OUTLET) IBOutlet CMCaptureImageModel*	outletCaptureVideoModel;
@property (ARC_PROP_OUTLET) IBOutlet id						outletCapturePreviewView;

@property (readonly)				dispatch_queue_t		captureVideoQueue;
@property (readonly)				dispatch_queue_t		captureSavingQueue;
@property (assign,readonly)			BOOL					captureSetupNeeded;
@property (assign,readonly)			BOOL					captureTeardownNeeded;

- (void)captureSetup;
- (void)captureTeardown;

- (IBAction)actionCaptureSnapshot:(id)sender;

- (NSString*)captureStillPictureFileName;
- (void)captureDisplayErrorOnMainQueue:(NSError *)error messageTitle:(NSString *)messageTitle;
- (BOOL)captureRequirementNilError:(NSError*)error message:(NSString*)message;
- (void)captureSnapStillPictureFromSampleBuffer:(CMSampleBufferRef)imageDataSampleBuffer;
- (void)captureWriteImageData:(NSData*)imageData imageMetadata:(id)imageMetadata;
- (void)captureOutputImageUsingDelegate:(CMCaptureImageModel*)model sampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)captureOutputImageUsingDelegate:(CMCaptureImageModel*)model imageBuffer:(CVImageBufferRef)imageBuffer;

@end
