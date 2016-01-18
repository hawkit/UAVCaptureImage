#import "CMCaptureImageModel.h"
#import "CMCaptureImageModelCIImage.h"
#import "RequiredAVFoundation.h"

@interface CMCaptureImageModel()
@end

@implementation CMCaptureImageModel

+ (id)imageMetadataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
NSDictionary* imageMetadata = [NSDictionary dictionary];
	if (REQUIRED_DEBUG(sampleBuffer!=NULL))
		{
	CFDictionaryRef bufferAttachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
		if (REQUIRED_DEBUG(bufferAttachments!=NULL))
			{
			REQUIRED_DEBUG(imageMetadata = [NSDictionary dictionaryWithDictionary:ARC_BRIDGE(NSDictionary*)bufferAttachments]);
			CFRelease(bufferAttachments);
			}
		}
	return imageMetadata;
}

+ (id)copyImageDataFromImageBuffer:(CVImageBufferRef)imageBuffer
{
	REQUIRED_DEBUG(imageBuffer!=NULL);
	return nil;
}

+ (id)copyImageDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
CIImage* sampleBufferImage = nil;
	if (REQUIRED_DEBUG(sampleBuffer!=NULL))
		{
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		if (REQUIRED_DEBUG(imageBuffer!=NULL))
			{
			REQUIRED_DEBUG(sampleBufferImage = [self copyImageDataFromImageBuffer:imageBuffer]);
			}
		}
	return sampleBufferImage;
}

#pragma mark -

ARC_SYNTHESIZE(imageData,__imageData);
ARC_SYNTHESIZE(imageMetadata,__imageMetadata);

- (instancetype)init
{
	if ((self=[super init])!=nil)
		{
		}
	return self;
}

- (void)dealloc
{
	ARC_DEALLOC_NIL(self.imageData);
	ARC_DEALLOC_NIL(self.imageMetadata);
	ARC_SUPERDEALLOC(self);
}

#pragma mark -

-(void) setImageDataWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
id sampleBufferImageData = nil;
	if (sampleBuffer!=NULL)
		sampleBufferImageData = [[self class] copyImageDataFromSampleBuffer:sampleBuffer];
	[self setImageData:sampleBufferImageData];
	self.imageMetadata = [[self class] imageMetadataFromSampleBuffer:sampleBuffer];
	if (sampleBufferImageData!=nil)
		ARC_RELEASE(sampleBufferImageData);
}

- (void)setImageDataWithCVImageBuffer:(CVImageBufferRef)imageBuffer
{
id imageBufferImageData = nil;
	if (imageBuffer!=NULL)
		imageBufferImageData = [[self class] copyImageDataFromImageBuffer:imageBuffer];
	[self setImageData:imageBufferImageData];
	self.imageMetadata = nil;
	if (imageBufferImageData!=nil)
		ARC_RELEASE(imageBufferImageData);
}

-(void) setImageDataWithImageData:(NSData*)imageData imageMetadata:(id)imageMetadata
{
	[self setImageData:imageData];
	[self setImageMetadata:imageMetadata];
}

-(NSString*) imageClassName
{
NSString* imageClassName = @"<?>";
	if (self.imageData!=nil) imageClassName = NSStringFromClass([(id)self.imageData class]);
	return imageClassName;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"{ %@ : %@ }", 
				self.imageClassName,
				self.imageMetadata];
}

@end
