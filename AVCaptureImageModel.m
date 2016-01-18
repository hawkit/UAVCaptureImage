#import "AVCaptureImageModel.h"

@interface AVCaptureImageModel()
@end

@implementation AVCaptureImageModel

+ (id)copyStillImageDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
NSData* imageData = nil;
#ifdef _DEBUG
//	CFShow(sampleBuffer);
#endif
	if (REQUIRED_DEBUG(sampleBuffer!=NULL) && REQUIRED_DEBUG(CMSampleBufferIsValid(sampleBuffer)))
		{
		@try {
			REQUIRED_DEBUG(imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer]);
			}
		@catch (NSException* x) {
			NSLOG_METHOD(x);
			}
		}
	if (imageData!=nil) imageData = [[NSData alloc] initWithData:imageData];
	return imageData;
}

@end
