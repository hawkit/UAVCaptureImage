#import "GKNibViewController.h"
#import "CMCaptureImagePopoverControllerProtocol.h"

#if !TARGET_OS_IPHONE

@interface QTKitCaptureImagePopoverMenuControllerOSX : GKNibViewController<CMCaptureImagePopoverControllerProtocol>

ARC_BEGIN_IVAR_DECL(QTKitCaptureImagePopoverMenuControllerOSX)
ARC_IVAR_DECLARE(NSImage*,currentImage,__currentImage);
ARC_IVAR_DECLARE(NSData*,imageData,__imageData);
ARC_IVAR_DECLARE(NSView*,outletPopoverMenuView,__outletPopoverMenuView);
ARC_END_IVAR_DECL(QTKitCaptureImagePopoverMenuControllerOSX)

@end

#endif /* !TARGET_OS_IPHONE */