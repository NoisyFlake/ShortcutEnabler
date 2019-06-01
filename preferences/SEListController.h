#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController (ShortcutEnabler)
-(void)_returnKeyPressed:(id)keyboard;
@end

@interface SEListController : PSListController

@end

@interface ShortcutEnablerLogo : PSTableCell {
	UILabel *background;
	UILabel *tweakName;
	UILabel *version;
}
@end
