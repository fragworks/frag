LOCAL_PATH := $(call my-dir)

# prepare libX
include $(CLEAR_VARS)
LOCAL_MODULE := bgfx
LOCAL_SRC_FILES := libbgfx-shared-libDebug.so
LOCAL_EXPORT_C_INCLUDES := ../../../../../../3rd/bgfx/include/bgfx
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL_PATH := ../SDL

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include

# Add your application source files here...
LOCAL_SRC_FILES := $(SDL_PATH)/src/main/android/SDL_android_main.c \
	$(patsubst $(LOCAL_PATH)/%, %, $(wildcard $(LOCAL_PATH)/*.cpp)) \
	$(patsubst $(LOCAL_PATH)/%, %, $(wildcard $(LOCAL_PATH)/*.c))

LOCAL_SHARED_LIBRARIES := SDL2 bgfx

LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -landroid -lEGL -llog

include $(BUILD_SHARED_LIBRARY)

