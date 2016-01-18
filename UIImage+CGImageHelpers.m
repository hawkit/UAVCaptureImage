#import "UIImage+CGImageHelpers.h"
#import "RequiredCoreVideo.h"

static void sReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static void sReleaseCVPixelBuffer(void *pixel, const void *data, size_t size) 
{	
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	CVPixelBufferRelease( pixelBuffer );
}

// create a CGImage with provided pixel buffer, pixel buffer must be uncompressed kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA
OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut) 
{	
CGImageRef image = NULL;
OSStatus err = noErr;
OSType sourcePixelFormat  = CVPixelBufferGetPixelFormatType( pixelBuffer );
CGBitmapInfo bitmapInfo = 0;
	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	else
		return -95014; // only uncompressed pixel formats
	
size_t sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
size_t width = CVPixelBufferGetWidth( pixelBuffer );
size_t height = CVPixelBufferGetHeight( pixelBuffer );
CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	REQUIRED_DEBUG(colorspace!=NULL);
	if (REQUIRED_CVRETURN(CVPixelBufferLockBaseAddress( pixelBuffer, 0 )))
		{
	void *sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
		if (REQUIRED_DEBUG(sourceBaseAddr!=NULL))
			{
		CGDataProviderRef provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, sReleaseCVPixelBuffer);
			if (REQUIRED_DEBUG(provider!=NULL))
				{
				CVPixelBufferRetain( pixelBuffer );
				image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
				REQUIRED_DEBUG(image!=NULL);
				CGDataProviderRelease( provider );
				}
			}
		}
	CGColorSpaceRelease( colorspace );
	*imageOut = image;
	return err;
}

// utility used by newSquareOverlayedImageForFeatures for 
CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow = (size.width * 4);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
									 size.width,
									 size.height,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing(context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}

#if TARGET_OS_IPHONE

@implementation UIImage (GravityRotation)


-(UIImage*)imageRotatedByDegrees:(CGFloat)degrees 
{   
// calculate the size of the rotated view's containing box for our drawing space
UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
CGSize rotatedSize = rotatedViewBox.frame.size;
	ARC_RELEASE(rotatedViewBox);
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

// utility routine used after taking a still image to write the resulting image to the camera roll
+ (BOOL)writeCGImageToCameraRoll:(CGImageRef)cgImage withMetadata:(NSDictionary*)metadata
{
BOOL success = NO;
CFMutableDataRef destinationData = CFDataCreateMutable(kCFAllocatorDefault, 0);
	if (REQUIRED_DEBUG(destinationData!=NULL))
		{
	CGImageDestinationRef destination = CGImageDestinationCreateWithData(destinationData, 
																		 CFSTR("public.jpeg"), 
																		 1, 
																		 NULL);
		if (REQUIRED_DEBUG(destination!=NULL))
			{
		const CGFloat JPEGCompQuality = 0.85f; // JPEGHigherQuality
		NSDictionary* optionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
													[NSNumber numberWithFloat:JPEGCompQuality],
													kCGImageDestinationLossyCompressionQuality,nil];
			CGImageDestinationAddImage( destination, cgImage, (CFDictionaryRef)optionsDict );
			success = CGImageDestinationFinalize( destination );
			CFRelease(destination);
			}

		CFRetain(destinationData);
		ALAssetsLibrary* library = [ALAssetsLibrary new];
			if (REQUIRED_DEBUG(library!=nil))
				{
				[library writeImageDataToSavedPhotosAlbum:ARC_BRIDGE(id)destinationData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
					if (destinationData)
						CFRelease(destinationData);
					}];
				ARC_RELEASE(library);
				}
		CFRelease(destinationData);
		}

	return success;
}

+(ImageOrientationEXIF) imageOrientationWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation usingFrontFacingCamera:(BOOL)usingFrontFacingCamera
{
int exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
/* kCGImagePropertyOrientation values
	The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
	by the TIFF and EXIF specifications -- see enumeration of integer constants. 
	The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
	
	used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
	If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
	
	switch (deviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (usingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (usingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
		}
	return (ImageOrientationEXIF)exifOrientation;
}

@end

#endif /* TARGET_OS_IPHONE */

