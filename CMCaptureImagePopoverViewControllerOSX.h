#import "RequiredAppUIKit.h"
#import "CMCaptureImageControllerBase.h"
#import "CMCaptureImagePopoverControllerProtocol.h"

#if !TARGET_OS_IPHONE

@interface CMCaptureImagePopoverViewControllerOSX : NSViewController<CMCaptureImagePopoverControllerProtocol>

ARC_BEGIN_IVAR_DECL(CMCaptureImagePopoverViewControllerOSX)
ARC_IVAR_DECLARE(NSImage*,currentImage,__currentImage);
ARC_IVAR_DECLARE(NSData*,imageData,__imageData);
@public
ARC_IVAR_DECLAREOUTLET(CMCaptureImageModel*,outletCaptureStillImage);
ARC_IVAR_DECLAREOUTLET(CMCaptureImageModel*,outletCaptureVideoImage);
ARC_IVAR_DECLAREOUTLET(CMCaptureImageControllerBase*,outletCaptureController);
@private
ARC_IVAR_DECLAREOUTLET(NSPopover*,outletPopover);
ARC_IVAR_DECLARE(NSPopover*,popover,__popover);
ARC_END_IVAR_DECL(CMCaptureImagePopoverViewControllerOSX)

@property (ARC_PROP_OUTLET) IBOutlet CMCaptureImageModel* outletCaptureStillImage;
@property (ARC_PROP_OUTLET) IBOutlet CMCaptureImageModel* outletCaptureVideoImage;
@property (ARC_PROP_OUTLET) IBOutlet NSPopover* outletPopover;

-(IBAction) actionPopoverDisplayWithPositioningViewSender:(NSView*)positioningView;

@end

#endif /* !TARGET_OS_IPHONE */