#import "RequiredCoreMedia.h"

@interface CMCaptureImageModel : NSObject
ARC_BEGIN_IVAR_DECL(AVCaptureImageModel)
ARC_IVAR_DECLARE(id,imageData,__imageData);
ARC_IVAR_DECLARE(id,imageMetadata,__imageMetadata);
ARC_END_IVAR_DECL(AVCaptureImageModel)

+ (id)imageMetadataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (id)copyImageDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (id)copyImageDataFromImageBuffer:(CVImageBufferRef)imageBuffer;

@property (copy) id<NSObject,NSCopying> imageData;
@property (retain) id imageMetadata;

- (void)setImageDataWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)setImageDataWithCVImageBuffer:(CVImageBufferRef)imageBuffer;
- (void)setImageDataWithImageData:(NSData*)imageData imageMetadata:(id)imageMetadata;

-(NSString*) description;

@end
