#import "CMCaptureImageModelCIImage.h"

@interface CMCaptureImageModelCIImage()
@end

@implementation CMCaptureImageModelCIImage

@dynamic imageData;

#if TARGET_OS_IPHONE

+ (UIImage*)imageWithCIImage:(CIImage*)image
{
UIImage* imageResult = nil;
CIContext* context = [CIContext contextWithOptions:nil];
	if (REQUIRED_DEBUG(context!=nil))
		{
	CGImageRef rasterizedImage = [context createCGImage:image fromRect:image.extent];
		if (REQUIRED_DEBUG(rasterizedImage!=NULL))
			{
			imageResult = [UIImage imageWithCGImage:rasterizedImage];
			CGImageRelease(rasterizedImage);
			}
		}
	return imageResult;
}

#endif /* TARGET_OS_IPHONE */

+ (id)copyStillImageDataFromImageBuffer:(CVImageBufferRef)imageBuffer
{ NSLOG_METHOD(imageBuffer);
NSData* imageData = nil;
	if (REQUIRED_DEBUGGER(imageBuffer!=NULL))
		{
	CIImage* image = [self copyImageDataFromImageBuffer:imageBuffer];
		if (REQUIRED_DEBUGGER(image!=nil))
			{
#if TARGET_OS_IPHONE
		UIImage* platformImage = [self imageWithCIImage:image];
			if (REQUIRED_DEBUG(platformImage!=nil))
				{
				imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(platformImage, 0.9f)];
				}
#else
		NSBitmapImageRep* bitmapImageRep = [[NSBitmapImageRep alloc] initWithCIImage:image];
			if (REQUIRED_DEBUG(bitmapImageRep!=NULL))
				{
			NSData* jpegData = [bitmapImageRep representationUsingType:NSJPEGFileType properties: nil];
				if (REQUIRED_DEBUG(jpegData!=nil))
					{
					imageData = [[NSData alloc] initWithData:jpegData];
					REQUIRED_DEBUG(imageData!=nil);
					}
				ARC_RELEASE(bitmapImageRep);
				}
#endif
			ARC_RELEASE(image);
			}
		}
	REQUIRED_DEBUG(imageData!=nil);
	return imageData;
}

+ (id)copyImageDataFromImageBuffer:(CVImageBufferRef)imageBuffer
{
CIImage* bufferImage = nil;
	if (REQUIRED_DEBUG(imageBuffer!=NULL))
		{
#if TARGET_OS_IPHONE
//	NSDictionary* attachments = [self imageMetadataFromSampleBuffer:sampleBuffer];
	NSDictionary* attachments = [NSDictionary dictionary];
		bufferImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:attachments];
#else /* MAC */
		bufferImage = [[CIImage alloc] initWithCVImageBuffer:imageBuffer];
#endif
		REQUIRED_DEBUGGER(bufferImage!=nil);
		}
	return bufferImage;
}

@end
