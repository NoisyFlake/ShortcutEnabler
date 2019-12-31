#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface UICoverSheetButton : UIControl
-(void)setEdgeInsets:(UIEdgeInsets)arg1;
@end

@interface SBFTouchPassThroughView : UIView
@property (nonatomic, retain) UICoverSheetButton *flashlightButton;
@property (nonatomic, retain) UICoverSheetButton *cameraButton;
- (UIEdgeInsets)_buttonOutsets;
- (void)_layoutQuickActionButtons;
- (void)handleButtonPress:(id)arg1;
@end


@interface SBDashBoardQuickActionsViewController : UIViewController
-(SBFTouchPassThroughView *)quickActionsViewIfLoaded;
@end

@interface SBDashBoardViewController : UIViewController
@end

@interface CSCoverSheetViewController : UIViewController
@end

@interface SBLockScreenManager : NSObject
@property (nonatomic, readonly) SBDashBoardViewController *dashBoardViewController;
@property (nonatomic,readonly) CSCoverSheetViewController * coverSheetViewController;
+(SBLockScreenManager *)sharedInstanceIfExists;
@end
