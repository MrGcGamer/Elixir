ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:latest

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Elixir

Elixir_FILES = Elixir.x
Elixir_CFLAGS = -fobjc-arc
Elixir_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk