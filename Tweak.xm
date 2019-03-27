#import "Tweak.h"

static BOOL showFlashlight, showCamera, require3DTouch;
static double flashlightX, flashlightY, cameraX, cameraY;

static BOOL settingsUpdated = NO;

%hook SBDashBoardQuickActionsViewController
+ (BOOL)deviceSupportsButtons {
	return YES;
}

- (BOOL)hasCamera {
	return showCamera;
}

- (BOOL)hasFlashlight {
	return showFlashlight;
}

- (void)touchBeganForButton:(id)arg1 {
	if (!require3DTouch) {
		[self fireActionForButton:arg1];
	} else {
		%orig(arg1);
	}
}
%end

%hook SBDashBoardQuickActionsView
- (void)_layoutQuickActionButtons {
	%orig;
	for (UIView *subview in self.subviews) {
		if (subview.frame.origin.x < 50) {
			CGRect flashlight = subview.frame;
			flashlight = CGRectMake(46 + flashlightX, (flashlight.origin.y - 90) + flashlightY, 50, 50);

			subview.frame = flashlight;
			[subview sb_removeAllSubviews];
			[subview init];
		} else if (subview.frame.origin.x > 100) {
			CGFloat _screenWidth = subview.frame.origin.x + subview.frame.size.width / 2;
			CGRect camera = subview.frame;
			camera = CGRectMake((_screenWidth - 96) + cameraX, (camera.origin.y - 90) + cameraY, 50, 50);

			subview.frame = camera;
			[subview sb_removeAllSubviews];
			[subview init];
		}
	}
}
-(void)_addOrRemoveCameraButtonIfNecessary {
	%orig;

	// Necessary to change the position of the buttons without a respring
	if (settingsUpdated) {
		[self _layoutQuickActionButtons];
		settingsUpdated = NO;
	}
}
%end

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.shortcutenabler.plist"];

	if (prefs) {
		showFlashlight = ( [prefs objectForKey:@"showFlashlight"] ? [[prefs objectForKey:@"showFlashlight"] boolValue] : YES );
		showCamera = ( [prefs objectForKey:@"showCamera"] ? [[prefs objectForKey:@"showCamera"] boolValue] : YES );
		require3DTouch = ( [prefs objectForKey:@"require3DTouch"] ? [[prefs objectForKey:@"require3DTouch"] boolValue] : YES );

		flashlightX = ( [prefs objectForKey:@"flashlightX"] ? [[prefs objectForKey:@"flashlightX"] doubleValue] : 0 );
		flashlightY = ( [prefs objectForKey:@"flashlightY"] ? [[prefs objectForKey:@"flashlightY"] doubleValue] : 0 );
		cameraX = ( [prefs objectForKey:@"cameraX"] ? [[prefs objectForKey:@"cameraX"] doubleValue] : 0 );
		cameraY = ( [prefs objectForKey:@"cameraY"] ? [[prefs objectForKey:@"cameraY"] doubleValue] : 0 );

		settingsUpdated = YES;
	}

	[prefs release];
}

static void initPrefs() {
	// Copy the default preferences file when the actual preference file doesn't exist
	NSString *path = @"/User/Library/Preferences/com.noisyflake.shortcutenabler.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/ShortcutEnabler.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.noisyflake.shortcutenabler/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	initPrefs();
	loadPrefs();
}
