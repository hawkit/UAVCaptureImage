#import "AVCaptureStoryboardPopoverSegueIOS.h"

#if TARGET_OS_IPHONE

#import "UIApplication+Utilities.h"

@interface UIStoryboardSegue(IOS8)
-(void) setPassthroughViews:(id)passthroughViews;
@end

#ifdef __IPHONE_9_0
@interface AVCaptureStoryboardPopoverSegueIOS()<UIPopoverPresentationControllerDelegate>
#else
@class UIPopoverPresentationController,UIPresentationController;
@protocol UIViewControllerTransitionCoordinator;
#define nullable
@interface AVCaptureStoryboardPopoverSegueIOS()
#endif
@property (assign) CGRect anchorFrame;
@property (assign,readonly) UIViewController* presentingViewController;
@property (assign,readonly) UIViewController* popoverViewController;
@end

@implementation AVCaptureStoryboardPopoverSegueIOS

@synthesize anchorFrame = __anchorFrame;

+(CGSize) preferredContentSize
{
CGRect rootWindowFrame = [UIApplication rootWindowFrame];
CGSize preferredSize = rootWindowFrame.size;
	if (preferredSize.width>preferredSize.height)
		preferredSize = CGSizeMake(rootWindowFrame.size.height,rootWindowFrame.size.width);
	if ([UIApplication versionNineOS])
		{
	CGFloat kScaleFactor = 0.8f;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
			kScaleFactor = 0.6f;
		preferredSize.width *= kScaleFactor;
		preferredSize.height *= kScaleFactor;
		}
	return preferredSize;
}


- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController*)source destination:(UIViewController *)destination
{
	NSLOG_METHOD(self);
	if ((self=[super initWithIdentifier:identifier source:source destination:destination]))
		{
		__anchorFrame = CGRectZero;
		@try {
			if (REQUIRED_DEBUG(self.presentingViewController!=nil))
				{
				}
			if (REQUIRED_DEBUG(self.popoverViewController!=nil))
				{
#ifdef __IPHONE_9_0
				self.popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
				if (REQUIRED_DEBUG(self.popoverViewController.popoverPresentationController!=nil))
					{
					self.popoverViewController.popoverPresentationController.delegate = self;
				NSString* preferredContentSize = NSStringFromCGSize(self.popoverViewController.preferredContentSize);
					NSLOG_METHOD(preferredContentSize);
					}
#endif
				}
			}
		@catch (NSException *x) {
			NSLOG_METHOD(x);
			}
		}
	return self;
}

-(void) dealloc
{
	ARC_SUPERDEALLOC(self);
}

#pragma mark -

-(void) setPassthroughViews:(id)passthroughViews
{
	NSLOG_METHOD(self);
#if 0
	if ([super respondsToSelector:@selector(setPassthroughViews:)])
		{
		[super setPassthroughViews:passthroughViews];
		}
#endif
}

-(void) setPermittedArrowDirections:(UIPopoverArrowDirection) permittedArrowDirections
{
	NSLOG_METHOD(self);
}

-(void) setAnchorBarButtonItem:(id)item
{
	NSLOG_METHOD(item);
	if ([item respondsToSelector:@selector(frame)])
		self.anchorFrame = [item frame];
}

-(UIPopoverArrowDirection) permittedArrowDirections
{
	return UIPopoverArrowDirectionUp;
}

#pragma mark -

-(UIViewController*) presentingViewController
{
	return self.sourceViewController;
}

-(UIViewController*) popoverViewController
{
	return self.destinationViewController;
}

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController*)popoverPresentationController
{
UIPopoverPresentationController* popover = popoverPresentationController;
	if (REQUIRED_DEBUG(popover!=nil))
		{
#ifdef __IPHONE_9_0
		popover.canOverlapSourceViewRect = NO;
	NSString* sourceRect = NSStringFromCGRect(popover.sourceView.bounds);
		NSLOG_METHOD(sourceRect);
#endif
  		}
}

- (void)presentationController:(UIPresentationController*)presentationController 
			willPresentWithAdaptiveStyle:(UIModalPresentationStyle)style 
			transitionCoordinator:(nullable id <UIViewControllerTransitionCoordinator>)transitionCoordinator
{
	NSLOG_METHOD(presentationController);
}

-(UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPopoverPresentationController*)presentationController
{
	NSLOG_METHOD(presentationController);
	return UIModalPresentationNone;
}

- (void) performOnCurrentVersionsOfIOS {
#ifdef __IPHONE_9_0
	REQUIRED_DEBUG(self.popoverViewController.modalPresentationStyle == UIModalPresentationPopover);
	self.popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
#endif
	[super perform];
}

- (void) performOnEarlierVersionsOfIOS {
UIViewController *sourceViewController = self.sourceViewController;
UIViewController *destinationViewController = self.destinationViewController;

	[destinationViewController prepareForSegue:self sender:self];

    [sourceViewController.view addSubview:destinationViewController.view];
    
    // Store original centre point of the destination view
CGPoint originalCenter = destinationViewController.view.center;
//	Set center to start point of the button
	destinationViewController.view.center = CGPointMake(originalCenter.x,originalCenter.y*2.0);
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         destinationViewController.view.center = originalCenter;
                     }
                     completion:^(BOOL finished){
						NSLOG_METHOD(self);
                     }];
}

- (void)perform
{
	if (REQUIRED_DEBUG(self.popoverViewController!=nil))
		{
		if (UIApplication.versionNineOS)
			[self performOnCurrentVersionsOfIOS];
		else
			[self performOnEarlierVersionsOfIOS];
		}
}

@end

#endif /* TARGET_OS_IPHONE */
