#import "CMCaptureImageModel.h"
#import "RequiredAVFoundation.h"

@interface AVCaptureImageModel : CMCaptureImageModel
+ (id)copyStillImageDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
