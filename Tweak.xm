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

static inline CGFloat GetButtonSize(CGRect screenBounds) {
	if (screenBounds.size.height > 812) return 58;
	if (screenBounds.size.height >= 736) return 50;
	return 42;
}

%hook ViewClass
- (void)_layoutQuickActionButtons {
	UIEdgeInsets insets = [self _buttonOutsets];
	[((SBFTouchPassThroughView *)self).flashlightButton setEdgeInsets:insets];
	[((SBFTouchPassThroughView *)self).cameraButton setEdgeInsets:insets];

	UIUserInterfaceLayoutDirection layoutDirection = [UIApplication sharedApplication].userInterfaceLayoutDirection;
	CGRect _referenceBounds = [UIScreen mainScreen]._referenceBounds;
	CGFloat buttonSize = GetButtonSize(_referenceBounds);
	CGFloat xOffsetPadding = layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft ? insets.right : insets.left;
	CGFloat buttonWidth = buttonSize + insets.right + insets.left;
	CGFloat buttonHeight = buttonSize + insets.top + insets.bottom;
	CGFloat offsetY = _referenceBounds.size.height - buttonHeight - insets.bottom;

	CGRect flashLightRect;
	CGRect cameraRect;
	if (layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
		flashLightRect = CGRectMake(_referenceBounds.size.width - xOffsetPadding - buttonWidth + flashlightX, offsetY + flashlightY, buttonWidth, buttonHeight);
		cameraRect = CGRectMake(xOffsetPadding + cameraX, offsetY + cameraY, buttonWidth, buttonHeight);
	} else {
		flashLightRect = CGRectMake(xOffsetPadding + flashlightX, offsetY + flashlightY, buttonWidth, buttonHeight);
		cameraRect = CGRectMake(_referenceBounds.size.width - xOffsetPadding - buttonHeight + cameraX, offsetY + cameraY, buttonWidth, buttonHeight);
	}
	((SBFTouchPassThroughView *)self).flashlightButton.frame = flashLightRect;
	((SBFTouchPassThroughView *)self).cameraButton.frame = cameraRect;
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

		showFlashlight = ( [[prefs objectForKey:@"showFlashlight"] boolValue]);
		showCamera = ( [[prefs objectForKey:@"showCamera"] boolValue]);
		require3DTouch = ([[prefs objectForKey:@"require3DTouch"] boolValue]);

		flashlightX = ( [[prefs objectForKey:@"flashlightX"] doubleValue]);
		flashlightY = ( [[prefs objectForKey:@"flashlightY"] doubleValue]);
		cameraX = ( [[prefs objectForKey:@"cameraX"] doubleValue]);
		cameraY = ( [[prefs objectForKey:@"cameraY"] doubleValue]);

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
