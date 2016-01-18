#import "AVCaptureImageController.h"
#import "AVCaptureImageWithFacesModel.h"

@class CIDetector;

@interface AVCaptureImageWithFacesController : AVCaptureImageController

ARC_BEGIN_IVAR_DECL(AVCaptureImageWithFacesController)
ARC_IVAR_DECLARE(NSArray*,faceFeatures,__faceFeatures);
@protected
ARC_IVAR_DECLARE(BOOL,detectFaces,__detectFaces);
ARC_IVAR_DECLARE(CIDetector*,faceDetector,__faceDetector);
ARC_END_IVAR_DECL(AVCaptureImageWithFacesController)

@property (assign) BOOL detectFaces;
@property (ARC_PROP_STRONG,readonly) NSArray* faceFeatures;
@property (ARC_PROP_STRONG,readonly,nonatomic) CIDetector* faceDetector;

@end
