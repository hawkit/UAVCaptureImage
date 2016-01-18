#import "AVCaptureImageWithFacesController.h"

#if TARGET_OS_IPHONE

#import "RequiredCoreImage.h"

#import <AssertMacros.h>
#import "UIImage+CGImageHelpers.h"

#pragma mark-

@interface AVCaptureImageWithFacesController ()
@property (ARC_PROP_STRONG,readwrite) CIDetector* faceDetector;
@end

@implementation AVCaptureImageWithFacesController

ARC_SYNTHESIZE(faceDetector,__faceDetector);
ARC_SYNTHESIZE(faceFeatures,__faceFeatures);
ARC_SYNTHESIZE(detectFaces,__detectFaces);

-(instancetype) init
{
	if ((self=[super init])!=nil)
		{
		__detectFaces = NO;
		}
	return self;
}

- (void)dealloc
{
	ARC_DEALLOC_NIL(self.faceDetector);

	ARC_SUPERDEALLOC(self);
}

-(BOOL) detectFaces
{
	return __detectFaces;
}

-(void) setDetectFaces:(BOOL) detectFaces
{
	__detectFaces = detectFaces;
	if (REQUIRED_DEBUG(self.captureVideoCaptureConnection!=nil))
		[self.captureVideoCaptureConnection setEnabled:detectFaces];
	[self setFaceFeatures:[NSArray array]];
}

-(AVCaptureImageWithFacesModel*) captureFacesModel
{
	X_REQUIRED_DEBUG(self.outletCaptureVideoModel!=nil);
	return (AVCaptureImageWithFacesModel*)self.outletCaptureVideoModel;
}

-(void) setFaceFeatures:(NSArray*)faceFeatures
{
	if (REQUIRED_DEBUG(self.captureFacesModel!=nil))
		[self.captureFacesModel setCaptureInputFeatures:faceFeatures];
}

-(NSArray*) faceFeatures
{
NSArray* features = [NSArray array];
	if (REQUIRED_DEBUG(self.captureFacesModel!=nil))
		features = self.captureFacesModel.captureInputFeatures;
	return features;
}

-(NSDictionary*) captureStillImageOutputSettings
{
NSDictionary* defaultCaptureStillImageOutputSettings = [super captureStillImageOutputSettings];

BOOL doingFaceDetection = __detectFaces && (self.captureEffectiveScale == 1.0f);
    // set the appropriate pixel format / image type output setting depending on if we'll need an uncompressed image for
    // the possiblity of drawing the red square over top or if we're just writing a jpeg to the camera roll which is the trival case
    if (doingFaceDetection)
		defaultCaptureStillImageOutputSettings = @{ARC_BRIDGE(NSString*)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] };
	return defaultCaptureStillImageOutputSettings;
}

- (NSArray*) faceFeaturesWithCaptureImage:(CIImage*)captureImage sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
BOOL captureFrontFacing = self.captureIsUsingFrontFacingCamera;
UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
ImageOrientationEXIF exifOrientation = [UIImage imageOrientationWithDeviceOrientation:deviceOrientation usingFrontFacingCamera:captureFrontFacing];
NSDictionary* imageOptions = @{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]};
	return [self.faceDetector featuresInImage:captureImage options:imageOptions];
}

- (void)captureOutputImageUsingDelegate:(AVCaptureImageWithFacesModel*)image sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	if (REQUIRED_DEBUG([image isKindOfClass:[AVCaptureImageWithFacesModel class]]))
		{
		self.faceFeatures = [self faceFeaturesWithCaptureImage:image.imageData sampleBuffer:sampleBuffer];
		}
	[super captureOutputImageUsingDelegate:image sampleBuffer:sampleBuffer];
}

- (IBAction)actionCaptureSwitchFrontAndBackCameras:(id)sender
{
	self.faceFeatures = [NSArray array];
	[super actionCaptureSwitchFrontAndBackCameras:sender];
}

- (void)captureSetup
{
    [super captureSetup];

NSDictionary* detectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
	self.faceFeatures = [NSArray array];
	
//	[self updateFaceDetectorBoolean];
}

@end

#endif /* TARGET_OS_IPHONE */

