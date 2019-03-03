include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ShortcutEnabler
ShortcutEnabler_FILES = $(wildcard *.m)
ShortcutEnabler_INSTALL_PATH = /Library/PreferenceBundles
ShortcutEnabler_FRAMEWORKS = CoreGraphics UIKit
ShortcutEnabler_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShortcutEnabler.plist$(ECHO_END)
