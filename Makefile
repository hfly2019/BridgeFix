CC := xcrun --sdk iphoneos clang
SDK_PATH := $(shell xcrun --sdk iphoneos --show-sdk-path)
ARCHS := -arch arm64 -arch arm64e
MIN_IOS := 15.0

CFLAGS := -O2 -shared -framework Foundation -framework WebKit \
          -isysroot $(SDK_PATH) -miphoneos-version-min=$(MIN_IOS) \
          -install_name @executable_path/BridgeFix.dylib

TARGET := build/BridgeFix.dylib
SRC := src/BridgeFix.m

all: $(TARGET)

$(TARGET): $(SRC)
	@mkdir -p build
	@echo "Building $@..."
	$(CC) $(ARCHS) $(CFLAGS) -o $@ $<
	@codesign -s - --force $@
	@echo "Done! Verifying:"
	@lipo -info $@

clean:
	rm -rf build

.PHONY: all clean
