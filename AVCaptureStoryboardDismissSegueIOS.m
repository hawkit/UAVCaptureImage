#import "AVCaptureStoryboardDismissSegueIOS.h"

#if TARGET_OS_IPHONE

@interface AVCaptureStoryboardDismissSegue()
@end

@implementation AVCaptureStoryboardDismissSegue

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController*)source destination:(UIViewController *)destination
{
	if ((self=[super initWithIdentifier:identifier source:source destination:destination]))
		{
		}
	return self;
}

-(void) dealloc
{
	ARC_SUPERDEALLOC(self);
}

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

#endif /* TARGET_OS_IPHONE */
