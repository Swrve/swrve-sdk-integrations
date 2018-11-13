#import "Swrve.h"
#import "SwrveMessageViewController.h"
#import "SwrveButton.h"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SwrveMessageViewController ()

@property (nonatomic, retain) SwrveMessageFormat* current_format;
@property (nonatomic) BOOL wasShownToUserNotified;
@property (nonatomic) CGFloat viewportWidth;
@property (nonatomic) CGFloat viewportHeight;

@property (nonatomic, retain) UIFocusGuide *focusGuide1;
@property (nonatomic, retain) UIFocusGuide *focusGuide2;
@property (nonatomic, retain) UIButton *tvOSFocusForSelection;

@end

@implementation SwrveMessageViewController

@synthesize block;
@synthesize message;
@synthesize current_format;
@synthesize wasShownToUserNotified;
@synthesize viewportWidth;
@synthesize viewportHeight;
@synthesize prefersIAMStatusBarHidden;

@synthesize focusGuide1, focusGuide2, tvOSFocusForSelection;

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // Default viewport size to whole screen
    CGRect screenRect = [[[UIApplication sharedApplication] keyWindow] bounds];
    self.viewportWidth = screenRect.size.width;
    self.viewportHeight = screenRect.size.height;
#if TARGET_OS_TV
    UITapGestureRecognizer *playPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonSelected)];
    playPress.allowedPressTypes = @[[NSNumber numberWithInteger:UIPressTypePlayPause]];
    [self.view addGestureRecognizer:playPress];
#endif
}

- (void)buttonSelected {
    [self onButtonPressed:self.tvOSFocusForSelection];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self updateBounds];
    [self removeAllViews];
    if(SYSTEM_VERSION_LESS_THAN(@"9.0")){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#if TARGET_OS_IOS /** exclude tvOS **/
        [self addViewForOrientation:[self interfaceOrientation]];
#endif
#pragma clang diagnostic pop
    } else {
        [self displayForViewportOfSize:CGSizeMake(self.viewportWidth, self.viewportHeight)];
        [self refreshViewForPlatform];
    }
    if (self.wasShownToUserNotified == NO) {
        [self.message wasShownToUser];
        self.wasShownToUserNotified = YES;
    }
}

-(void)updateBounds
{
    // Update the bounds to the new screen size
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    [self refreshViewForPlatform];
}

-(void)removeAllViews
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
}

-(void)refreshViewForPlatform {
    // pre-iOS 9 setNeedsFocusUpdate and updateFocusIfNeeded are not supported
#if TARGET_OS_TV
    [self.view setNeedsFocusUpdate];
    [self.view updateFocusIfNeeded];
#endif
}


#if TARGET_OS_IOS /** exclude tvOS **/
-(void)addViewForOrientation:(UIInterfaceOrientation)orientation
{
    current_format = [self.message bestFormatForOrientation:orientation];
    if (!current_format) {
        // Never leave the screen without a format
        current_format = [self.message.formats objectAtIndex:0];
    }
    
    if (current_format) {
        DebugLog(@"Selected message format: %@", current_format.name);
        [current_format createViewToFit:self.view
                                  thatDelegatesTo:self
                                         withSize:self.view.bounds.size
                                          rotated:false];
        
        // Update background color
        if (current_format.backgroundColor != nil) {
            self.view.backgroundColor = current_format.backgroundColor;
        }
    } else {
        DebugLog(@"Couldn't find a format for message: %@", message.name);
    }
}
#endif

-(IBAction)onButtonPressed:(id)sender
{
    UIButton* button = sender;

    SwrveButton* pressed = [current_format.buttons objectAtIndex:(NSUInteger)button.tag];
    [pressed wasPressedByUser];

    self.block(pressed.actionType, pressed.actionString, pressed.appID);
}

#if defined(__IPHONE_8_0)
-(BOOL)prefersStatusBarHidden
{
    if (prefersIAMStatusBarHidden) {
        return YES;
    } else {
        return [super prefersStatusBarHidden];
    }
}
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    self.viewportWidth = size.width;
    self.viewportHeight = size.height;
    [self removeAllViews];
    [self displayForViewportOfSize:CGSizeMake(self.viewportWidth, self.viewportHeight)];
}
#endif //defined(__IPHONE_8_0)

- (void) displayForViewportOfSize:(CGSize)size
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        float viewportRatio = (float)(size.width/size.height);
        float closestRatio = -1;
        SwrveMessageFormat* closestFormat = nil;
        for (SwrveMessageFormat* format in self.message.formats) {
            float formatRatio = (float)(format.size.width/format.size.height);
            float diffRatio = fabsf(formatRatio - viewportRatio);
            if (closestFormat == nil || (diffRatio < closestRatio)) {
                closestFormat = format;
                closestRatio = diffRatio;
            }
        }
    
        current_format = closestFormat;
        DebugLog(@"Selected message format: %@", current_format.name);
        UIView *currentView = [current_format createViewToFit:self.view
                       thatDelegatesTo:self
                              withSize:size];

        [self setupFocusGuide:currentView];
        
        [currentView setHidden:NO];
        [currentView setUserInteractionEnabled:YES];
        [currentView setAlpha:1.0];
        
    } else {
#if TARGET_OS_IOS /** exclude tvOS **/
        UIInterfaceOrientation currentOrientation = (size.width > size.height)? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
        
        BOOL mustRotate = false;
        current_format = [self.message bestFormatForOrientation:currentOrientation];
        if (!current_format) {
            // Never leave the screen without a format
            current_format = [self.message.formats objectAtIndex:0];
            mustRotate = true;
        }
        
        if (current_format) {
            DebugLog(@"Selected message format: %@", current_format.name);
            [current_format createViewToFit:self.view
                           thatDelegatesTo:self
                                  withSize:size
                                   rotated:mustRotate];
        } else {
            DebugLog(@"Couldn't find a format for message: %@", message.name);
        }
#endif
    }
    // Update background color
    if (current_format.backgroundColor != nil) {
        self.view.backgroundColor = current_format.backgroundColor;
    }
}

// iOS 6 and iOS 7 (to be deprecated)
#if defined(__IPHONE_9_0)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif //defined(__IPHONE_9_0)
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        return UIInterfaceOrientationMaskAll;
    } else {
#if TARGET_OS_IOS /** exclude tvOS **/
        BOOL portrait = [self.message supportsOrientation:UIInterfaceOrientationPortrait];
        BOOL landscape = [self.message supportsOrientation:UIInterfaceOrientationLandscapeLeft];
        
        if (portrait && landscape) {
            return UIInterfaceOrientationMaskAll;
        }
        
        if (landscape) {
            return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        }
#endif
    }
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Focus
- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
#pragma unused(coordinator)
    
    UIView *previouslyFocusedView = context.previouslyFocusedView;
    
    if (previouslyFocusedView != nil && [previouslyFocusedView isDescendantOfView:self.view]) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
            previouslyFocusedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
#pragma unused(finished)
        }];
        
    }
    
    UIView *nextFocusedView = context.nextFocusedView;
    
    if (nextFocusedView != nil && [nextFocusedView isDescendantOfView:self.view]) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
            
            CGFloat increase = (float)1.2;
            
            nextFocusedView.transform = CGAffineTransformMakeScale(increase, increase);
        } completion:^(BOOL finished) {
#pragma unused(finished)
        }];
        
        self.tvOSFocusForSelection = (UIButton *)nextFocusedView;

        UIButton *nextFocusableButton = [self nextFocusableButtonWithCurrentFocusedView:nextFocusedView];
        self.focusGuide1.preferredFocusedView = nextFocusableButton;
        self.focusGuide2.preferredFocusedView = nextFocusableButton;
    }
}

- (void)setupFocusGuide:(UIView *)currentView {
    self.focusGuide1 = nil;
    self.focusGuide2 = nil;
    NSArray<UIButton *> *buttons = [SwrveMessageViewController buttonsInView:currentView];
    if (buttons.count != 2) { // we only want to help focus engine if there are two buttons
        return;
    }


    CGRect frame0 = buttons[0].frame;
    CGRect frame1 = buttons[1].frame;
    // only add focus guides if the buttons are strictly diagonal. otherwise the focus engine will figure it out by itself
    if ((CGRectGetMinY(frame1) > CGRectGetMaxY(frame0) || CGRectGetMaxY(frame1) < CGRectGetMinY(frame0))
         &&
         (CGRectGetMinX(frame1) > CGRectGetMaxX(frame0) || CGRectGetMaxX(frame1) < CGRectGetMinX(frame0))) {

        self.focusGuide1 = [UIFocusGuide new];
        [currentView addLayoutGuide:self.focusGuide1];
        [self.focusGuide1.leftAnchor constraintEqualToAnchor:buttons[0].leftAnchor].active = YES;
        [self.focusGuide1.rightAnchor constraintEqualToAnchor:buttons[0].rightAnchor].active = YES;
        [self.focusGuide1.topAnchor constraintEqualToAnchor:buttons[1].topAnchor].active = YES;
        [self.focusGuide1.bottomAnchor constraintEqualToAnchor:buttons[1].bottomAnchor].active = YES;

        self.focusGuide2 = [UIFocusGuide new];
        [currentView addLayoutGuide:self.focusGuide2];
        [self.focusGuide2.leftAnchor constraintEqualToAnchor:buttons[1].leftAnchor].active = YES;
        [self.focusGuide2.rightAnchor constraintEqualToAnchor:buttons[1].rightAnchor].active = YES;
        [self.focusGuide2.topAnchor constraintEqualToAnchor:buttons[0].topAnchor].active = YES;
        [self.focusGuide2.bottomAnchor constraintEqualToAnchor:buttons[0].bottomAnchor].active = YES;
      
        /*
        // Debug focus guide
        UIView *v1 = [UIView new];
        v1.backgroundColor = [UIColor redColor];
        v1.frame = self.focusGuide1.layoutFrame;
        [currentView addSubview:v1];

        UIView *v2 = [UIView new];
        v2.backgroundColor = [UIColor redColor];
        v2.frame = self.focusGuide2.layoutFrame;
        [currentView addSubview:v2];
         */
    }

}

- (UIButton *)nextFocusableButtonWithCurrentFocusedView:(UIView *)view {
    NSArray *allButtons = [SwrveMessageViewController buttonsInView:self.view];
    if (allButtons.count < 2) {
        return nil;
    }
    // Here we are finding the next focusable button that is then set (by the caller) as the preferred focusable view for the focusGuide.
    NSUInteger idx = [allButtons indexOfObject:view];
    if (idx == NSNotFound) {
        return nil;
    }
    // The following lines are equivalent to: return allButtons[(idx+1) % allButtons.count], i.e. we find the next button in the array, or if there are none we return the first button.
    if (idx == allButtons.count - 1) {
        return allButtons.firstObject;
    }
    return allButtons[idx + 1];
}

+ (NSArray<UIButton *> *)buttonsInView:(UIView *)view {
    NSMutableArray *result = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        [result addObjectsFromArray:[self buttonsInView:subview]];
        if ([subview isKindOfClass:[UIButton class]]) {
            [result addObject:subview];
        }
    }
    return result;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
#if TARGET_OS_IOS /** exclude tvOS **/
    if(SYSTEM_VERSION_LESS_THAN(@"8.0")){
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }
#endif
}

@end
