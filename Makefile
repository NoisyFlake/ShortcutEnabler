TARGET = iphone:clang:11.2:11.2
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ShortcutEnabler
ShortcutEnabler_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
