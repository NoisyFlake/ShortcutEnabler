@interface UIView (SpringBoardAdditions)
- (void)sb_removeAllSubviews;
@end

@interface SBDashBoardQuickActionsView : UIView
- (void)_layoutQuickActionButtons;
- (void)handleButtonPress:(id)arg1 ;
@end

@interface CSQuickActionsView : UIView
- (void)_layoutQuickActionButtons;
-(void)handleButtonPress:(id)arg1 ;
@end
