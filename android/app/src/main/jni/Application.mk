
# Uncomment this if you're using STL in your project
# See CPLUSPLUS-SUPPORT.html in the NDK documentation for more information
APP_STL := c++_shared

APP_ABI := armeabi-v7a

#  Enable C++11. However, pthread, rtti and exceptions aren’t enabled 
APP_CPPFLAGS += -std=c++11

APP_CPPFLAGS += -fexceptions

# Min SDK level
APP_PLATFORM=android-15

NDK_TOOLCHAIN_VERSION := 4.9