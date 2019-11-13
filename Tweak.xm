#import "Tweak.h"

static BOOL showFlashlight, showCamera, require3DTouch;
static double flashlightX, flashlightY, cameraX, cameraY;

static BOOL settingsUpdated = NO;

%hook ControllerClass
+ (BOOL)deviceSupportsButtons {
	return YES;
}

- (BOOL)hasCamera {
	return showCamera;
}

- (BOOL)hasFlashlight {
	return showFlashlight;
}
%end

%hook ViewClass
- (void)_layoutQuickActionButtons {
	%orig;
	for (UIView *subview in ((UIView*)self).subviews) {

		if (subview.frame.origin.x < 50) {
			CGRect flashlight = subview.frame;

			// Fix for Jumper: The extra buttons are already aligned above the original ones, so don't change their Y position
			CGFloat flashlightOffset = subview.alpha > 0 ? (flashlight.origin.y - 90 + flashlightY) : flashlight.origin.y;

			flashlight = CGRectMake(46 + flashlightX, flashlightOffset, 50, 50);

			subview.frame = flashlight;
			[subview sb_removeAllSubviews];
			[subview init];
		} else {
			CGFloat _screenWidth = [UIScreen mainScreen].bounds.size.width;
			CGRect camera = subview.frame;

			// Fix for Jumper: The extra buttons are already aligned above the original ones, so don't change their Y position
			CGFloat cameraOffset = subview.alpha > 0 ? (camera.origin.y - 90 + cameraY) : camera.origin.y;

			camera = CGRectMake((_screenWidth - 96) + cameraX, cameraOffset, 50, 50);

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

-(void)handleButtonTouchBegan:(id)arg1 {
	require3DTouch ? %orig(arg1) : [self handleButtonPress:arg1];
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

	Class controllerClass;
	Class viewClass;

	if (@available(iOS 13, *)) {
		controllerClass = %c(CSQuickActionsViewController);
		viewClass = %c(CSQuickActionsView);
	} else {
		controllerClass = %c(SBDashBoardQuickActionsViewController);
		viewClass = %c(SBDashBoardQuickActionsView);
	}

	%init(ControllerClass=controllerClass,ViewClass=viewClass);
}
