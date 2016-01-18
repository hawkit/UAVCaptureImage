#import "RequiredAppUIKit.h"
#import "CMCaptureImageControllerBase.h"

#if !TARGET_OS_IPHONE

@protocol CMCaptureImagePopoverControllerProtocol<NSObject>
@property (ARC_PROP_STRONG) NSData* currentImageData;
@property (ARC_PROP_STRONG) NSImage* currentImage;
@end

#endif /* !TARGET_OS_IPHONE */