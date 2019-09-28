@interface SBDashBoardQuickActionsButton : UIView
-(void)setEdgeInsets:(UIEdgeInsets)arg1;
@end

@interface SBDashBoardQuickActionsView : UIView
@property (nonatomic, retain) SBDashBoardQuickActionsButton *flashlightButton;
@property (nonatomic, retain) SBDashBoardQuickActionsButton *cameraButton;
- (UIEdgeInsets)_buttonOutsets;
- (void)_layoutQuickActionButtons;
- (void)handleButtonPress:(id)arg1;
@end

@interface SBDashBoardQuickActionsViewController : UIViewController
-(SBDashBoardQuickActionsView *)quickActionsViewIfLoaded;
@end

@interface UIScreen (ShortcutEnablerPrivate)
@property (nonatomic, readonly) CGRect _referenceBounds;
@end

@interface SBDashBoardViewController : UIViewController
@end

@interface SBLockScreenManager : NSObject
@property (nonatomic, readonly) SBDashBoardViewController *dashBoardViewController;
+(SBLockScreenManager *)sharedInstanceIfExists;
@end