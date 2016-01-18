#import "RequiredAppUIKit.h"

@interface GKNibViewController : NSObject

ARC_BEGIN_IVAR_DECL(GKNSViewWithNibController)
ARC_IVAR_DECLAREOUTLET(id,outletViewHolder);
ARC_IVAR_DECLAREOUTLET(id,outletView);
ARC_IVAR_DECLARE(NSInteger,constructed,__constructed);
ARC_END_IVAR_DECL(GKNSViewWithNibController)

@property (ARC_PROP_OUTLET) IBOutlet id outletViewHolder;

- (NSString*)nibLoadNameDefault;
- (BOOL)nibLoadOnThisVersionOfOSX;
- (BOOL)nibLoadConstructed;
- (void)nibLoadAwakeFromNibOnce;

@end
