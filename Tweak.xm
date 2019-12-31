#import "Tweak.h"

static BOOL showFlashlight, showCamera, require3DTouch;
static CGFloat flashlightX, flashlightY, cameraX, cameraY;

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
	UIEdgeInsets insets = [self _buttonOutsets];
    	CGRect screenBounds = [UIScreen mainScreen].bounds;
	CGFloat offsetY = screenBounds.size.height - 90 - insets.top;
	
    	((SBFTouchPassThroughView *)self).flashlightButton.frame = CGRectMake(46 + flashlightX, offsetY + flashlightY, 50, 50);
	((SBFTouchPassThroughView *)self).cameraButton.frame = CGRectMake(screenBounds.size.width - 96 + cameraX, offsetY + cameraY, 50, 50);
}

-(void)handleButtonTouchBegan:(id)arg1 {
	require3DTouch ? %orig(arg1) : [self handleButtonPress:arg1];
}
%end

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.shortcutenabler.plist"];

	if (prefs) {
		CGFloat prevFlashlightX = flashlightX;
		CGFloat prevFlashlightY = flashlightY;
		CGFloat prevCameraX = cameraX;
		CGFloat prevCameraY = cameraY;

		showFlashlight = ( [prefs objectForKey:@"showFlashlight"] ? [[prefs objectForKey:@"showFlashlight"] boolValue] : YES );
		showCamera = ( [prefs objectForKey:@"showCamera"] ? [[prefs objectForKey:@"showCamera"] boolValue] : YES );
		require3DTouch = ( [prefs objectForKey:@"require3DTouch"] ? [[prefs objectForKey:@"require3DTouch"] boolValue] : YES );

		flashlightX = ( [prefs objectForKey:@"flashlightX"] ? [[prefs objectForKey:@"flashlightX"] doubleValue] : 0 );
		flashlightY = ( [prefs objectForKey:@"flashlightY"] ? [[prefs objectForKey:@"flashlightY"] doubleValue] : 0 );
		cameraX = ( [prefs objectForKey:@"cameraX"] ? [[prefs objectForKey:@"cameraX"] doubleValue] : 0 );
		cameraY = ( [prefs objectForKey:@"cameraY"] ? [[prefs objectForKey:@"cameraY"] doubleValue] : 0 );

		// force update the layout if preferences changed
		if (prevFlashlightX != flashlightX || prevFlashlightY != flashlightY || prevCameraX != cameraX || prevCameraY != cameraY) {

			if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
				CSCoverSheetViewController *controller = [%c(SBLockScreenManager) sharedInstanceIfExists].coverSheetViewController;
				CSQuickActionsViewController *quickActionsViewController = [controller valueForKey:@"_quickActionsViewController"];
				[[quickActionsViewController quickActionsViewIfLoaded] _layoutQuickActionButtons];
			} else {
				SBDashBoardViewController *controller = [%c(SBLockScreenManager) sharedInstanceIfExists].dashBoardViewController;
				SBDashBoardQuickActionsViewController *quickActionsViewController = [controller valueForKey:@"_quickActionsViewController"];
				[[quickActionsViewController quickActionsViewIfLoaded] _layoutQuickActionButtons];

			}
		}
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

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
		controllerClass = %c(CSQuickActionsViewController);
		viewClass = %c(CSQuickActionsView);
	} else {
		controllerClass = %c(SBDashBoardQuickActionsViewController);
		viewClass = %c(SBDashBoardQuickActionsView);
	}

	%init(ControllerClass=controllerClass,ViewClass=viewClass);
}
