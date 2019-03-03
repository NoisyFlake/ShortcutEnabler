#line 1 "Tweak.xm"
#import "Tweak.h"

static BOOL showFlashlight, showCamera, require3DTouch;


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBDashBoardQuickActionsView; @class SBDashBoardQuickActionsViewController; 
static BOOL (*_logos_meta_orig$_ungrouped$SBDashBoardQuickActionsViewController$deviceSupportsButtons)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static BOOL _logos_meta_method$_ungrouped$SBDashBoardQuickActionsViewController$deviceSupportsButtons(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$hasCamera)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$_ungrouped$SBDashBoardQuickActionsViewController$hasCamera(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$hasFlashlight)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$_ungrouped$SBDashBoardQuickActionsViewController$hasFlashlight(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$touchBeganForButton$)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBDashBoardQuickActionsViewController$touchBeganForButton$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$SBDashBoardQuickActionsView$_layoutQuickActionButtons)(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsView* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBDashBoardQuickActionsView$_layoutQuickActionButtons(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsView* _LOGOS_SELF_CONST, SEL); 

#line 5 "Tweak.xm"

static BOOL _logos_meta_method$_ungrouped$SBDashBoardQuickActionsViewController$deviceSupportsButtons(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	return YES;
}

static BOOL _logos_method$_ungrouped$SBDashBoardQuickActionsViewController$hasCamera(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	return showCamera;
}

static BOOL _logos_method$_ungrouped$SBDashBoardQuickActionsViewController$hasFlashlight(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	return showFlashlight;
}

static void _logos_method$_ungrouped$SBDashBoardQuickActionsViewController$touchBeganForButton$(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
	if (!require3DTouch) {
		[self fireActionForButton:arg1];
	} else {
		_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$touchBeganForButton$(self, _cmd, arg1);
	}
}



static void _logos_method$_ungrouped$SBDashBoardQuickActionsView$_layoutQuickActionButtons(_LOGOS_SELF_TYPE_NORMAL SBDashBoardQuickActionsView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$_ungrouped$SBDashBoardQuickActionsView$_layoutQuickActionButtons(self, _cmd);
    for (UIView *subview in self.subviews) {
        if (subview.frame.size.width < 50) {
            if (subview.frame.origin.x < 50) {
                CGRect _frame = subview.frame;
                _frame = CGRectMake(46, _frame.origin.y - 90, 50, 50);
                subview.frame = _frame;
                [subview sb_removeAllSubviews];
                [subview init];
            }
            if (subview.frame.origin.x > 100) {
                CGFloat _screenWidth = subview.frame.origin.x + subview.frame.size.width / 2;
                CGRect _frame = subview.frame;
                _frame = CGRectMake(_screenWidth - 96, _frame.origin.y - 90, 50, 50);
                subview.frame = _frame;
                [subview sb_removeAllSubviews];
                [subview init];
            }
        }
    }
}


static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.shortcutenabler.plist"];

	if (prefs) {
		showFlashlight = ( [prefs objectForKey:@"showFlashlight"] ? [[prefs objectForKey:@"showFlashlight"] boolValue] : YES );
		showCamera = ( [prefs objectForKey:@"showCamera"] ? [[prefs objectForKey:@"showCamera"] boolValue] : YES );
		require3DTouch = ( [prefs objectForKey:@"require3DTouch"] ? [[prefs objectForKey:@"require3DTouch"] boolValue] : YES );
	}

	[prefs release];
}

static void initPrefs() {
	
	NSString *path = @"/User/Library/Preferences/com.noisyflake.shortcutenabler.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/ShortcutEnabler.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

static __attribute__((constructor)) void _logosLocalCtor_4c282753(int __unused argc, char __unused **argv, char __unused **envp) {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.noisyflake.shortcutenabler/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBDashBoardQuickActionsViewController = objc_getClass("SBDashBoardQuickActionsViewController"); Class _logos_metaclass$_ungrouped$SBDashBoardQuickActionsViewController = object_getClass(_logos_class$_ungrouped$SBDashBoardQuickActionsViewController); MSHookMessageEx(_logos_metaclass$_ungrouped$SBDashBoardQuickActionsViewController, @selector(deviceSupportsButtons), (IMP)&_logos_meta_method$_ungrouped$SBDashBoardQuickActionsViewController$deviceSupportsButtons, (IMP*)&_logos_meta_orig$_ungrouped$SBDashBoardQuickActionsViewController$deviceSupportsButtons);MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardQuickActionsViewController, @selector(hasCamera), (IMP)&_logos_method$_ungrouped$SBDashBoardQuickActionsViewController$hasCamera, (IMP*)&_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$hasCamera);MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardQuickActionsViewController, @selector(hasFlashlight), (IMP)&_logos_method$_ungrouped$SBDashBoardQuickActionsViewController$hasFlashlight, (IMP*)&_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$hasFlashlight);MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardQuickActionsViewController, @selector(touchBeganForButton:), (IMP)&_logos_method$_ungrouped$SBDashBoardQuickActionsViewController$touchBeganForButton$, (IMP*)&_logos_orig$_ungrouped$SBDashBoardQuickActionsViewController$touchBeganForButton$);Class _logos_class$_ungrouped$SBDashBoardQuickActionsView = objc_getClass("SBDashBoardQuickActionsView"); MSHookMessageEx(_logos_class$_ungrouped$SBDashBoardQuickActionsView, @selector(_layoutQuickActionButtons), (IMP)&_logos_method$_ungrouped$SBDashBoardQuickActionsView$_layoutQuickActionButtons, (IMP*)&_logos_orig$_ungrouped$SBDashBoardQuickActionsView$_layoutQuickActionButtons);} }
#line 79 "Tweak.xm"
