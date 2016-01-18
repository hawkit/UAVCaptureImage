#import "RequiredAppUIKit.h"

#import <ImageIO/ImageIO.h>

static inline CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180.0;};
extern CGContextRef CreateCGBitmapContextForSize(CGSize size);
extern OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);

#if TARGET_OS_IPHONE

#import <AssetsLibrary/AssetsLibrary.h>

typedef enum tagImageOrientationEXIF {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.  
	} ImageOrientationEXIF;
	

@interface UIImage (CGImageHelpers)
-(UIImage*)imageRotatedByDegrees:(CGFloat)degrees;
+(BOOL)writeCGImageToCameraRoll:(CGImageRef)cgImage withMetadata:(NSDictionary*)metadata;
+(ImageOrientationEXIF) imageOrientationWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation usingFrontFacingCamera:(BOOL)usingFrontFacingCamera;
@end

#endif /* TARGET_OS_IPHONE */
