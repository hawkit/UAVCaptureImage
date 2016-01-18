#import "AVCaptureImageModelCIImage.h"

@interface AVCaptureImageWithFacesModel : AVCaptureImageModelCIImage

ARC_BEGIN_IVAR_DECL(AVCaptureImageWithFacesModel)
ARC_IVAR_DECLARE(NSArray*,captureInputFeatures,__captureInputFeatures);
ARC_END_IVAR_DECL(AVCaptureImageWithFacesModel)

@property (ARC_PROP_STRONG) NSArray* captureInputFeatures;

@end
