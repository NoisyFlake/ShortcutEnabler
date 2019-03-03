@interface UIView (SpringBoardAdditions)
- (void)sb_removeAllSubviews;
@end

@interface SBDashBoardQuickActionsView : UIView
-(void)fireActionForButton:(id)arg1;
-(void)touchEndedForButton:(id)arg1 ;
-(void)_launchCamera;
@end
