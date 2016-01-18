#import "AVCaptureImageWithFacesModel.h"

@interface AVCaptureImageWithFacesModel()
@end

@implementation AVCaptureImageWithFacesModel

ARC_SYNTHESIZE(captureInputFeatures,__captureInputFeatures);

-(void) dealloc
{
	ARC_DEALLOC_NIL(self.captureInputFeatures);
	ARC_SUPERDEALLOC(self);
}


@end
