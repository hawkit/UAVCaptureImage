#import "GKNibViewController.h"

@interface GKNibViewController()
@property (ARC_PROP_OUTLET) IBOutlet id outletView;
@property (ARC_PROP_STRONG) NSArray* topLevelObjects;
@property (assign,readwrite) NSInteger constructed;
@property (assign) BOOL constructedSuccess;
@end

@implementation GKNibViewController

ARC_SYNTHESIZEOUTLET(outletViewHolder);
ARC_SYNTHESIZEOUTLET(outletView);
ARC_SYNTHESIZE(topLevelObjects,__topLevelObjects);
ARC_SYNTHESIZE(constructed,__constructed);

- (void) dealloc {
	ARC_DEALLOC_NIL(self.topLevelObjects);
	ARC_SUPERDEALLOC(self);
}

- (NSString*)nibLoadNameDefault {
	return NSStringFromClass([self class]);
}

- (BOOL)nibLoadConstructed	{
	return (self.constructed!=0) && REQUIRED_DEBUG(self.topLevelObjects!=nil);
}

- (BOOL)nibLoadOnThisVersionOfOSX {
	return YES;
}

-(BOOL) loadObjectGraphWithNibName:(NSString*)nibName
{ // NSLOG(@"NSUIViewNibbler:instantiateObjectGraphWithNibName:%@\n", nibName);
BOOL result = NO;
	if (REQUIRED_DEBUG(self.constructed == 0))
		{
		self.constructed += 1;
		self.topLevelObjects = nil;
		if (self.nibLoadOnThisVersionOfOSX && REQUIRED_DEBUG(self.outletViewHolder!=nil))
			{
			@try
				{
			NSNib* classNib = [[NSNib alloc] initWithNibNamed:nibName bundle:nil];
				if (REQUIRED_DEBUG(classNib!=nil))
					{
				NSArray* receivesTopLevelObjects = nil;
					if (REQUIRED_DEBUG([classNib instantiateNibWithOwner:self topLevelObjects:&receivesTopLevelObjects]))
						{
						self.topLevelObjects = receivesTopLevelObjects;
						result = REQUIRED_DEBUG(receivesTopLevelObjects!=nil) && REQUIRED_DEBUG(self.outletView!=nil);
						}
					ARC_RELEASE(classNib);
					}
				}
			@catch (NSException* x)
				{
				NSLOG_METHOD(x);
				}
			}
		}
	return result;
}

#if TARGET_OS_PHONE

- (void) awakeFromNibInstallSubview:(UIView*)view {
	#error
}

#else

- (void) awakeFromNibInstallSubview:(NSView*)outletView {
NSRect initialSubViewFrame = [outletView frame];
	[self.outletViewHolder addSubview:outletView];
	[outletView resizeWithOldSuperviewSize:initialSubViewFrame.size];
	[outletView setNeedsDisplay:YES];
}

#endif

- (void) awakeFromNib {
	if (self.constructed==0)
		{
		if (REQUIRED_DEBUG([self loadObjectGraphWithNibName:self.nibLoadNameDefault]))
			{
			if (REQUIRED_DEBUG(self.outletViewHolder!=nil) && REQUIRED_DEBUG(self.outletView!=nil))
				{
				[self awakeFromNibInstallSubview:self.outletView];
				[self nibLoadAwakeFromNibOnce];
				}
			}
		}
}

- (void) nibLoadAwakeFromNibOnce {
	NSLOG_METHOD(self);
	REQUIRED_DEBUG(self.outletView!=nil);
}

@end
