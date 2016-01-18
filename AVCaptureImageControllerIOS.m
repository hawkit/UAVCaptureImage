#import "AVCaptureImageControllerIOS.h"

#if TARGET_OS_IPHONE

#import <AssertMacros.h>
#import "UIImage+CGImageHelpers.h"
#import "UIApplication+Utilities.h"
#import "AVCaptureImageModel.h"

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static NSString* const AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
static NSString* const AVCapture_IsCapturingStillImageKeyPath = @"capturingStillImage";

@interface AVCaptureImageControllerIOS ()<UIGestureRecognizerDelegate>

@property (ARC_PROP_STRONG) UIView* flashView;
@property (assign,nonatomic) CGFloat beginGestureScale;

- (IBAction)actionPinchGestureRecognized:(UIGestureRecognizer*)sender;
@end

@implementation AVCaptureImageControllerIOS

ARC_SYNTHESIZE(flashView,__flashView);
ARC_SYNTHESIZE(beginGestureScale,__beginGestureScale);

- (void)dealloc
{
	ARC_DEALLOC_NIL(self.flashView);
	ARC_SUPERDEALLOC(self);
}

- (void)captureDisplayErrorOnMainQueue:(NSError *)error messageTitle:(NSString *)messageTitle
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", messageTitle, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK",@"OK") 
												  otherButtonTitles:nil];
		[alertView show];
		ARC_RELEASE(alertView);
	});
}

- (NSString*)captureSessionPreset
{
NSString* captureSessionPreset = [super captureSessionPreset];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    captureSessionPreset = AVCaptureSessionPreset640x480;
	return captureSessionPreset;
}

- (void)captureSetup
{
	__beginGestureScale = 1.0f;
	[super captureSetup];
}

-(CALayer*) capturePreviewRootLayer
{
CALayer* previewRootLayer = nil;
UIView* capturePreviewView = self.outletCapturePreviewView;
	if (REQUIRED_DEBUG(self.outletCapturePreviewView!=nil) && REQUIRED_DEBUG(capturePreviewView.layer!=nil))
		{
		previewRootLayer = (capturePreviewView.layer);
		}
	return previewRootLayer;
}

- (BOOL)captureSetupPreviewUI
{
BOOL succeeded = [super captureSetupPreviewUI];
	[self.captureStillImageOutput addObserver:self forKeyPath:AVCapture_IsCapturingStillImageKeyPath options:NSKeyValueObservingOptionNew context:(void*)AVCaptureStillImageIsCapturingStillImageContext];
	if (REQUIRED_DEBUG(self.capturePreviewLayer!=nil))
		{
		[self.capturePreviewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
		[self.capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
		}
	return succeeded;
}

- (void)captureTeardown
{
	if (self.captureTeardownNeeded)
		{
		if (REQUIRED_DEBUG(self.captureStillImageOutput!=nil))
			{
			@try {
				[self.captureStillImageOutput removeObserver:self forKeyPath:AVCapture_IsCapturingStillImageKeyPath];
				}
			@catch (NSException* x) {
				NSLOG_METHOD(x);
				}
			}
		[super captureTeardown];
		}
}

#pragma mark -

- (void)captureFlashViewAnimationForCapturingStillImage:(BOOL)capturingStillImage
{
const CGFloat kFlashDuration = 0.4f;
const CGFloat kFlashOpaque = 1.0f;
const CGFloat kFlashTransparent = 0.0f;
	if ( capturingStillImage ) {
		self.flashView = nil;
		__flashView = [[UIView alloc] initWithFrame:[UIApplication rootWindowFrame]];
		self.flashView.backgroundColor = [UIColor whiteColor];
		self.flashView.alpha = 0.0f;
		[[UIApplication rootWindow] addSubview:self.flashView];
		
		[UIView animateWithDuration:kFlashDuration
			 animations:^{
				 self.flashView.alpha = kFlashOpaque;
			 }];
	}
	else {
		[UIView animateWithDuration:kFlashDuration
			 animations:^{
				 self.flashView.alpha = kFlashTransparent;
			 }
			 completion:^(BOOL finished){
				 [self.flashView removeFromSuperview];
				 self.flashView = nil;
			 }];
	}
}

// perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (self.captureIsUsingFrontFacingCamera)
		{
		if ( ARC_BRIDGE(void*)AVCaptureStillImageIsCapturingStillImageContext == context )
			{
		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
			[self captureFlashViewAnimationForCapturingStillImage:isCapturingStillImage];
			}
		}
}

- (AVCaptureVideoOrientation)captureOrientationForDeviceOrientation
{
UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

-(void) captureWriteImageData:(NSData*)imageData imageMetadata:(id)imageMetadata
{
ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if (REQUIRED_DEBUG(library!=nil))
		{
		[library writeImageDataToSavedPhotosAlbum:imageData
				metadata:imageMetadata 
				completionBlock:^(NSURL *assetURL, NSError* error) {
					REQUIRED_NSERROR_NIL(error);
					[self captureRequirementNilError:error message:NSLocalizedString(@"NOT SAVED",@"NOT SAVED")];
				}];
		ARC_RELEASE(library);
		}
}

- (IBAction)actionCaptureSwitchFrontAndBackCameras:(id)sender
{
AVCaptureDevicePosition desiredPosition;
	if (self.captureIsUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[self.capturePreviewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[self.capturePreviewLayer session] inputs]) {
				[[self.capturePreviewLayer session] removeInput:oldInput];
			}
			[[self.capturePreviewLayer session] addInput:input];
			[[self.capturePreviewLayer session] commitConfiguration];
			break;
		}
	}
	self.captureIsUsingFrontFacingCamera = !self.captureIsUsingFrontFacingCamera;
}

#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
	if (REQUIRED_DEBUG(recognizer!=nil) && REQUIRED_DEBUG([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]))
		__beginGestureScale = self.captureEffectiveScale;
	return YES;
}

- (IBAction)actionPinchGestureRecognized:(UIPinchGestureRecognizer*)recognizer
{
	if (REQUIRED_DEBUG(recognizer!=nil) && REQUIRED_DEBUG([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]))
		{
	BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = recognizer.numberOfTouches;
		for ( NSUInteger i = 0; i < numTouches; ++i )
			{
		CGPoint location = [recognizer locationOfTouch:i inView:self.outletCapturePreviewView];
		CGPoint convertedLocation = [self.capturePreviewLayer convertPoint:location fromLayer:self.capturePreviewLayer.superlayer];
			if ( ! [self.capturePreviewLayer containsPoint:convertedLocation] )
				{
				allTouchesAreOnThePreviewLayer = NO;
				break;
				}
			}
		
		if ( allTouchesAreOnThePreviewLayer )
			{
			self.captureEffectiveScale = self.beginGestureScale * recognizer.scale;
			if (self.captureEffectiveScale < 1.0f)self.captureEffectiveScale = 1.0f;
		CGFloat maxScaleAndCropFactor = [[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
			if (self.captureEffectiveScale > maxScaleAndCropFactor) self.captureEffectiveScale = maxScaleAndCropFactor;
			[CATransaction begin];
			[CATransaction setAnimationDuration:.025f];
			[self.capturePreviewLayer setAffineTransform:CGAffineTransformMakeScale(self.captureEffectiveScale, self.captureEffectiveScale)];
			[CATransaction commit];
			}
		}
}

@end

#endif /* TARGET_OS_IPHONE */
