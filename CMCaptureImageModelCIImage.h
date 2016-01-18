#import "CMCaptureImageModel.h"
#import "RequiredCoreImage.h"

@interface CMCaptureImageModelCIImage : CMCaptureImageModel

+ (id)copyStillImageDataFromImageBuffer:(CVImageBufferRef)imageBuffer;
+ (id)copyImageDataFromImageBuffer:(CVImageBufferRef)imageBuffer;

@property (copy) CIImage* imageData;

@end
