 {.deadCodeElim: on.}
when defined(windows):
  const
    libname* = "libsoloud.dll"
elif defined(macosx):
  const
    libname* = "libsoloud.dylib"
else:
  const
    libname* = "libsoloud.so"
##  **************************************************
##   WARNING: this is a generated file. Do not edit. *
##   Any edits will be overwritten by the generator. *
## *************************************************
## 
## SoLoud audio engine
## Copyright (c) 2013-2016 Jari Komppa
## 
## This software is provided 'as-is', without any express or implied
## warranty. In no event will the authors be held liable for any damages
## arising from the use of this software.
## 
## Permission is granted to anyone to use this software for any purpose,
## including commercial applications, and to alter it and redistribute it
## freely, subject to the following restrictions:
## 
##    1. The origin of this software must not be misrepresented; you must not
##    claim that you wrote the original software. If you use this software
##    in a product, an acknowledgment in the product documentation would be
##    appreciated but is not required.
## 
##    2. Altered source versions must be plainly marked as such, and must not be
##    misrepresented as being the original software.
## 
##    3. This notice may not be removed or altered from any source
##    distribution.
## 
##  SoLoud C-Api Code Generator (c)2013-2016 Jari Komppa http://iki.fi/sol/

##  Collected enumerations

type
  SOLOUD_ENUMS* {.size: sizeof(cint).} = enum
    SOLOUD_AUTO = 0, SOLOUD_SDL = 1, SOLOUD_SDL2 = 2, SOLOUD_PORTAUDIO = 3,
    SOLOUD_WINMM = 4, SOLOUD_XAUDIO2 = 5, SOLOUD_WASAPI = 6, SOLOUD_ALSA = 7,
    SOLOUD_OSS = 8, SOLOUD_OPENAL = 9, SOLOUD_COREAUDIO = 10, SOLOUD_OPENSLES = 11,
    SOLOUD_NULLDRIVER = 12, SOLOUD_BACKEND_MAX = 13

const
  BIQUADRESONANTFILTER_NONE = SOLOUD_AUTO
  BIQUADRESONANTFILTER_WET = SOLOUD_AUTO
  LOFIFILTER_WET = SOLOUD_AUTO
  BASSBOOSTFILTER_WET = SOLOUD_AUTO
  SFXR_COIN = SOLOUD_AUTO
  FLANGERFILTER_WET = SOLOUD_AUTO
  MONOTONE_SQUARE = SOLOUD_AUTO
  SOLOUD_CLIP_ROUNDOFF = SOLOUD_SDL
  BIQUADRESONANTFILTER_LOWPASS = SOLOUD_SDL
  BIQUADRESONANTFILTER_SAMPLERATE = SOLOUD_SDL
  LOFIFILTER_SAMPLERATE = SOLOUD_SDL
  BASSBOOSTFILTER_BOOST = SOLOUD_SDL
  SFXR_LASER = SOLOUD_SDL
  FLANGERFILTER_DELAY = SOLOUD_SDL
  MONOTONE_SAW = SOLOUD_SDL
  SOLOUD_ENABLE_VISUALIZATION = SOLOUD_SDL2
  BIQUADRESONANTFILTER_HIGHPASS = SOLOUD_SDL2
  BIQUADRESONANTFILTER_FREQUENCY = SOLOUD_SDL2
  LOFIFILTER_BITDEPTH = SOLOUD_SDL2
  SFXR_EXPLOSION = SOLOUD_SDL2
  FLANGERFILTER_FREQ = SOLOUD_SDL2
  MONOTONE_SIN = SOLOUD_SDL2
  BIQUADRESONANTFILTER_BANDPASS = SOLOUD_PORTAUDIO
  BIQUADRESONANTFILTER_RESONANCE = SOLOUD_PORTAUDIO
  SFXR_POWERUP = SOLOUD_PORTAUDIO
  MONOTONE_SAWSIN = SOLOUD_PORTAUDIO
  SOLOUD_LEFT_HANDED_3D = SOLOUD_WINMM
  SFXR_HURT = SOLOUD_WINMM
  SFXR_JUMP = SOLOUD_XAUDIO2
  SFXR_BLIP = SOLOUD_WASAPI

##  Object handle typedefs

type
  AlignedFloatBuffer* = pointer
  Soloud* = pointer
  AudioCollider* = pointer
  AudioAttenuator* = pointer
  AudioSource* = pointer
  BiquadResonantFilter* = pointer
  LofiFilter* = pointer
  Bus* = pointer
  EchoFilter* = pointer
  Fader* = pointer
  FFTFilter* = pointer
  BassboostFilter* = pointer
  Filter* = pointer
  Speech* = pointer
  Wav* = pointer
  WavStream* = pointer
  Prg* = pointer
  Sfxr* = pointer
  FlangerFilter* = pointer
  DCRemovalFilter* = pointer
  Openmpt* = pointer
  Monotone* = pointer
  TedSid* = pointer
  File* = pointer

## 
##  Soloud
## 

proc Soloud_destroy*(aSoloud: ptr Soloud) {.cdecl, importc: "Soloud_destroy",
                                        dynlib: libname.}
proc Soloud_create*(): ptr Soloud {.cdecl, importc: "Soloud_create", dynlib: libname.}
proc Soloud_init*(aSoloud: ptr Soloud): cint {.cdecl, importc: "Soloud_init",
    dynlib: libname.}
proc Soloud_initEx*(aSoloud: ptr Soloud; aFlags: cuint; ##  = Soloud::CLIP_ROUNDOFF
                   aBackend: cuint; ##  = Soloud::AUTO
                   aSamplerate: cuint; ##  = Soloud::AUTO
                   aBufferSize: cuint; ##  = Soloud::AUTO
                   aChannels: cuint): cint {.cdecl, importc: "Soloud_initEx",
    dynlib: libname.}
  ##  = 2
proc Soloud_deinit*(aSoloud: ptr Soloud) {.cdecl, importc: "Soloud_deinit",
                                       dynlib: libname.}
proc Soloud_getVersion*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getVersion", dynlib: libname.}
proc Soloud_getErrorString*(aSoloud: ptr Soloud; aErrorCode: cint): cstring {.cdecl,
    importc: "Soloud_getErrorString", dynlib: libname.}
proc Soloud_getBackendId*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getBackendId", dynlib: libname.}
proc Soloud_getBackendString*(aSoloud: ptr Soloud): cstring {.cdecl,
    importc: "Soloud_getBackendString", dynlib: libname.}
proc Soloud_getBackendChannels*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getBackendChannels", dynlib: libname.}
proc Soloud_getBackendSamplerate*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getBackendSamplerate", dynlib: libname.}
proc Soloud_getBackendBufferSize*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getBackendBufferSize", dynlib: libname.}
proc Soloud_setSpeakerPosition*(aSoloud: ptr Soloud; aChannel: cuint; aX: cfloat;
                               aY: cfloat; aZ: cfloat): cint {.cdecl,
    importc: "Soloud_setSpeakerPosition", dynlib: libname.}
proc Soloud_play*(aSoloud: ptr Soloud; aSound: ptr AudioSource): cuint {.cdecl,
    importc: "Soloud_play", dynlib: libname.}
proc Soloud_playEx*(aSoloud: ptr Soloud; aSound: ptr AudioSource; aVolume: cfloat; ##  = -1.0f
                   aPan: cfloat; ##  = 0.0f
                   aPaused: cint; ##  = 0
                   aBus: cuint): cuint {.cdecl, importc: "Soloud_playEx",
                                      dynlib: libname.}
  ##  = 0
proc Soloud_playClocked*(aSoloud: ptr Soloud; aSoundTime: cdouble;
                        aSound: ptr AudioSource): cuint {.cdecl,
    importc: "Soloud_playClocked", dynlib: libname.}
proc Soloud_playClockedEx*(aSoloud: ptr Soloud; aSoundTime: cdouble;
                          aSound: ptr AudioSource; aVolume: cfloat; ##  = -1.0f
                          aPan: cfloat; ##  = 0.0f
                          aBus: cuint): cuint {.cdecl,
    importc: "Soloud_playClockedEx", dynlib: libname.}
  ##  = 0
proc Soloud_play3d*(aSoloud: ptr Soloud; aSound: ptr AudioSource; aPosX: cfloat;
                   aPosY: cfloat; aPosZ: cfloat): cuint {.cdecl,
    importc: "Soloud_play3d", dynlib: libname.}
proc Soloud_play3dEx*(aSoloud: ptr Soloud; aSound: ptr AudioSource; aPosX: cfloat;
                     aPosY: cfloat; aPosZ: cfloat; aVelX: cfloat; ##  = 0.0f
                     aVelY: cfloat; ##  = 0.0f
                     aVelZ: cfloat; ##  = 0.0f
                     aVolume: cfloat; ##  = 1.0f
                     aPaused: cint; ##  = 0
                     aBus: cuint): cuint {.cdecl, importc: "Soloud_play3dEx",
                                        dynlib: libname.}
  ##  = 0
proc Soloud_play3dClocked*(aSoloud: ptr Soloud; aSoundTime: cdouble;
                          aSound: ptr AudioSource; aPosX: cfloat; aPosY: cfloat;
                          aPosZ: cfloat): cuint {.cdecl,
    importc: "Soloud_play3dClocked", dynlib: libname.}
proc Soloud_play3dClockedEx*(aSoloud: ptr Soloud; aSoundTime: cdouble;
                            aSound: ptr AudioSource; aPosX: cfloat; aPosY: cfloat;
                            aPosZ: cfloat; aVelX: cfloat; ##  = 0.0f
                            aVelY: cfloat; ##  = 0.0f
                            aVelZ: cfloat; ##  = 0.0f
                            aVolume: cfloat; ##  = 1.0f
                            aBus: cuint): cuint {.cdecl,
    importc: "Soloud_play3dClockedEx", dynlib: libname.}
  ##  = 0
proc Soloud_seek*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aSeconds: cdouble) {.cdecl,
    importc: "Soloud_seek", dynlib: libname.}
proc Soloud_stop*(aSoloud: ptr Soloud; aVoiceHandle: cuint) {.cdecl,
    importc: "Soloud_stop", dynlib: libname.}
proc Soloud_stopAll*(aSoloud: ptr Soloud) {.cdecl, importc: "Soloud_stopAll",
                                        dynlib: libname.}
proc Soloud_stopAudioSource*(aSoloud: ptr Soloud; aSound: ptr AudioSource) {.cdecl,
    importc: "Soloud_stopAudioSource", dynlib: libname.}
proc Soloud_setFilterParameter*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                               aFilterId: cuint; aAttributeId: cuint; aValue: cfloat) {.
    cdecl, importc: "Soloud_setFilterParameter", dynlib: libname.}
proc Soloud_getFilterParameter*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                               aFilterId: cuint; aAttributeId: cuint): cfloat {.
    cdecl, importc: "Soloud_getFilterParameter", dynlib: libname.}
proc Soloud_fadeFilterParameter*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                aFilterId: cuint; aAttributeId: cuint; aTo: cfloat;
                                aTime: cdouble) {.cdecl,
    importc: "Soloud_fadeFilterParameter", dynlib: libname.}
proc Soloud_oscillateFilterParameter*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                     aFilterId: cuint; aAttributeId: cuint;
                                     aFrom: cfloat; aTo: cfloat; aTime: cdouble) {.
    cdecl, importc: "Soloud_oscillateFilterParameter", dynlib: libname.}
proc Soloud_getStreamTime*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cdouble {.cdecl,
    importc: "Soloud_getStreamTime", dynlib: libname.}
proc Soloud_getPause*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cint {.cdecl,
    importc: "Soloud_getPause", dynlib: libname.}
proc Soloud_getVolume*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cfloat {.cdecl,
    importc: "Soloud_getVolume", dynlib: libname.}
proc Soloud_getOverallVolume*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cfloat {.
    cdecl, importc: "Soloud_getOverallVolume", dynlib: libname.}
proc Soloud_getPan*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cfloat {.cdecl,
    importc: "Soloud_getPan", dynlib: libname.}
proc Soloud_getSamplerate*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cfloat {.cdecl,
    importc: "Soloud_getSamplerate", dynlib: libname.}
proc Soloud_getProtectVoice*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cint {.cdecl,
    importc: "Soloud_getProtectVoice", dynlib: libname.}
proc Soloud_getActiveVoiceCount*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getActiveVoiceCount", dynlib: libname.}
proc Soloud_getVoiceCount*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getVoiceCount", dynlib: libname.}
proc Soloud_isValidVoiceHandle*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cint {.
    cdecl, importc: "Soloud_isValidVoiceHandle", dynlib: libname.}
proc Soloud_getRelativePlaySpeed*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cfloat {.
    cdecl, importc: "Soloud_getRelativePlaySpeed", dynlib: libname.}
proc Soloud_getPostClipScaler*(aSoloud: ptr Soloud): cfloat {.cdecl,
    importc: "Soloud_getPostClipScaler", dynlib: libname.}
proc Soloud_getGlobalVolume*(aSoloud: ptr Soloud): cfloat {.cdecl,
    importc: "Soloud_getGlobalVolume", dynlib: libname.}
proc Soloud_getMaxActiveVoiceCount*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_getMaxActiveVoiceCount", dynlib: libname.}
proc Soloud_getLooping*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cint {.cdecl,
    importc: "Soloud_getLooping", dynlib: libname.}
proc Soloud_setLooping*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aLooping: cint) {.
    cdecl, importc: "Soloud_setLooping", dynlib: libname.}
proc Soloud_setMaxActiveVoiceCount*(aSoloud: ptr Soloud; aVoiceCount: cuint): cint {.
    cdecl, importc: "Soloud_setMaxActiveVoiceCount", dynlib: libname.}
proc Soloud_setInaudibleBehavior*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                 aMustTick: cint; aKill: cint) {.cdecl,
    importc: "Soloud_setInaudibleBehavior", dynlib: libname.}
proc Soloud_setGlobalVolume*(aSoloud: ptr Soloud; aVolume: cfloat) {.cdecl,
    importc: "Soloud_setGlobalVolume", dynlib: libname.}
proc Soloud_setPostClipScaler*(aSoloud: ptr Soloud; aScaler: cfloat) {.cdecl,
    importc: "Soloud_setPostClipScaler", dynlib: libname.}
proc Soloud_setPause*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aPause: cint) {.cdecl,
    importc: "Soloud_setPause", dynlib: libname.}
proc Soloud_setPauseAll*(aSoloud: ptr Soloud; aPause: cint) {.cdecl,
    importc: "Soloud_setPauseAll", dynlib: libname.}
proc Soloud_setRelativePlaySpeed*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                 aSpeed: cfloat): cint {.cdecl,
    importc: "Soloud_setRelativePlaySpeed", dynlib: libname.}
proc Soloud_setProtectVoice*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aProtect: cint) {.
    cdecl, importc: "Soloud_setProtectVoice", dynlib: libname.}
proc Soloud_setSamplerate*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                          aSamplerate: cfloat) {.cdecl,
    importc: "Soloud_setSamplerate", dynlib: libname.}
proc Soloud_setPan*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aPan: cfloat) {.cdecl,
    importc: "Soloud_setPan", dynlib: libname.}
proc Soloud_setPanAbsolute*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                           aLVolume: cfloat; aRVolume: cfloat) {.cdecl,
    importc: "Soloud_setPanAbsolute", dynlib: libname.}
proc Soloud_setPanAbsoluteEx*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                             aLVolume: cfloat; aRVolume: cfloat; aLBVolume: cfloat; ##  = 0
                             aRBVolume: cfloat; ##  = 0
                             aCVolume: cfloat; ##  = 0
                             aSVolume: cfloat) {.cdecl,
    importc: "Soloud_setPanAbsoluteEx", dynlib: libname.}
  ##  = 0
proc Soloud_setVolume*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aVolume: cfloat) {.
    cdecl, importc: "Soloud_setVolume", dynlib: libname.}
proc Soloud_setDelaySamples*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aSamples: cuint) {.
    cdecl, importc: "Soloud_setDelaySamples", dynlib: libname.}
proc Soloud_fadeVolume*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aTo: cfloat;
                       aTime: cdouble) {.cdecl, importc: "Soloud_fadeVolume",
                                       dynlib: libname.}
proc Soloud_fadePan*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aTo: cfloat;
                    aTime: cdouble) {.cdecl, importc: "Soloud_fadePan",
                                    dynlib: libname.}
proc Soloud_fadeRelativePlaySpeed*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                  aTo: cfloat; aTime: cdouble) {.cdecl,
    importc: "Soloud_fadeRelativePlaySpeed", dynlib: libname.}
proc Soloud_fadeGlobalVolume*(aSoloud: ptr Soloud; aTo: cfloat; aTime: cdouble) {.cdecl,
    importc: "Soloud_fadeGlobalVolume", dynlib: libname.}
proc Soloud_schedulePause*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aTime: cdouble) {.
    cdecl, importc: "Soloud_schedulePause", dynlib: libname.}
proc Soloud_scheduleStop*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aTime: cdouble) {.
    cdecl, importc: "Soloud_scheduleStop", dynlib: libname.}
proc Soloud_oscillateVolume*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aFrom: cfloat;
                            aTo: cfloat; aTime: cdouble) {.cdecl,
    importc: "Soloud_oscillateVolume", dynlib: libname.}
proc Soloud_oscillatePan*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aFrom: cfloat;
                         aTo: cfloat; aTime: cdouble) {.cdecl,
    importc: "Soloud_oscillatePan", dynlib: libname.}
proc Soloud_oscillateRelativePlaySpeed*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                       aFrom: cfloat; aTo: cfloat; aTime: cdouble) {.
    cdecl, importc: "Soloud_oscillateRelativePlaySpeed", dynlib: libname.}
proc Soloud_oscillateGlobalVolume*(aSoloud: ptr Soloud; aFrom: cfloat; aTo: cfloat;
                                  aTime: cdouble) {.cdecl,
    importc: "Soloud_oscillateGlobalVolume", dynlib: libname.}
proc Soloud_setGlobalFilter*(aSoloud: ptr Soloud; aFilterId: cuint;
                            aFilter: ptr Filter) {.cdecl,
    importc: "Soloud_setGlobalFilter", dynlib: libname.}
proc Soloud_setVisualizationEnable*(aSoloud: ptr Soloud; aEnable: cint) {.cdecl,
    importc: "Soloud_setVisualizationEnable", dynlib: libname.}
proc Soloud_calcFFT*(aSoloud: ptr Soloud): ptr cfloat {.cdecl,
    importc: "Soloud_calcFFT", dynlib: libname.}
proc Soloud_getWave*(aSoloud: ptr Soloud): ptr cfloat {.cdecl,
    importc: "Soloud_getWave", dynlib: libname.}
proc Soloud_getLoopCount*(aSoloud: ptr Soloud; aVoiceHandle: cuint): cuint {.cdecl,
    importc: "Soloud_getLoopCount", dynlib: libname.}
proc Soloud_getInfo*(aSoloud: ptr Soloud; aVoiceHandle: cuint; aInfoKey: cuint): cfloat {.
    cdecl, importc: "Soloud_getInfo", dynlib: libname.}
proc Soloud_createVoiceGroup*(aSoloud: ptr Soloud): cuint {.cdecl,
    importc: "Soloud_createVoiceGroup", dynlib: libname.}
proc Soloud_destroyVoiceGroup*(aSoloud: ptr Soloud; aVoiceGroupHandle: cuint): cint {.
    cdecl, importc: "Soloud_destroyVoiceGroup", dynlib: libname.}
proc Soloud_addVoiceToGroup*(aSoloud: ptr Soloud; aVoiceGroupHandle: cuint;
                            aVoiceHandle: cuint): cint {.cdecl,
    importc: "Soloud_addVoiceToGroup", dynlib: libname.}
proc Soloud_isVoiceGroup*(aSoloud: ptr Soloud; aVoiceGroupHandle: cuint): cint {.cdecl,
    importc: "Soloud_isVoiceGroup", dynlib: libname.}
proc Soloud_isVoiceGroupEmpty*(aSoloud: ptr Soloud; aVoiceGroupHandle: cuint): cint {.
    cdecl, importc: "Soloud_isVoiceGroupEmpty", dynlib: libname.}
proc Soloud_update3dAudio*(aSoloud: ptr Soloud) {.cdecl,
    importc: "Soloud_update3dAudio", dynlib: libname.}
proc Soloud_set3dSoundSpeed*(aSoloud: ptr Soloud; aSpeed: cfloat): cint {.cdecl,
    importc: "Soloud_set3dSoundSpeed", dynlib: libname.}
proc Soloud_get3dSoundSpeed*(aSoloud: ptr Soloud): cfloat {.cdecl,
    importc: "Soloud_get3dSoundSpeed", dynlib: libname.}
proc Soloud_set3dListenerParameters*(aSoloud: ptr Soloud; aPosX: cfloat;
                                    aPosY: cfloat; aPosZ: cfloat; aAtX: cfloat;
                                    aAtY: cfloat; aAtZ: cfloat; aUpX: cfloat;
                                    aUpY: cfloat; aUpZ: cfloat) {.cdecl,
    importc: "Soloud_set3dListenerParameters", dynlib: libname.}
proc Soloud_set3dListenerParametersEx*(aSoloud: ptr Soloud; aPosX: cfloat;
                                      aPosY: cfloat; aPosZ: cfloat; aAtX: cfloat;
                                      aAtY: cfloat; aAtZ: cfloat; aUpX: cfloat;
                                      aUpY: cfloat; aUpZ: cfloat; aVelocityX: cfloat; ##  = 0.0f
                                      aVelocityY: cfloat; ##  = 0.0f
                                      aVelocityZ: cfloat) {.cdecl,
    importc: "Soloud_set3dListenerParametersEx", dynlib: libname.}
  ##  = 0.0f
proc Soloud_set3dListenerPosition*(aSoloud: ptr Soloud; aPosX: cfloat; aPosY: cfloat;
                                  aPosZ: cfloat) {.cdecl,
    importc: "Soloud_set3dListenerPosition", dynlib: libname.}
proc Soloud_set3dListenerAt*(aSoloud: ptr Soloud; aAtX: cfloat; aAtY: cfloat;
                            aAtZ: cfloat) {.cdecl,
    importc: "Soloud_set3dListenerAt", dynlib: libname.}
proc Soloud_set3dListenerUp*(aSoloud: ptr Soloud; aUpX: cfloat; aUpY: cfloat;
                            aUpZ: cfloat) {.cdecl,
    importc: "Soloud_set3dListenerUp", dynlib: libname.}
proc Soloud_set3dListenerVelocity*(aSoloud: ptr Soloud; aVelocityX: cfloat;
                                  aVelocityY: cfloat; aVelocityZ: cfloat) {.cdecl,
    importc: "Soloud_set3dListenerVelocity", dynlib: libname.}
proc Soloud_set3dSourceParameters*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                  aPosX: cfloat; aPosY: cfloat; aPosZ: cfloat) {.
    cdecl, importc: "Soloud_set3dSourceParameters", dynlib: libname.}
proc Soloud_set3dSourceParametersEx*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                    aPosX: cfloat; aPosY: cfloat; aPosZ: cfloat; aVelocityX: cfloat; ##  = 0.0f
                                    aVelocityY: cfloat; ##  = 0.0f
                                    aVelocityZ: cfloat) {.cdecl,
    importc: "Soloud_set3dSourceParametersEx", dynlib: libname.}
  ##  = 0.0f
proc Soloud_set3dSourcePosition*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                aPosX: cfloat; aPosY: cfloat; aPosZ: cfloat) {.cdecl,
    importc: "Soloud_set3dSourcePosition", dynlib: libname.}
proc Soloud_set3dSourceVelocity*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                aVelocityX: cfloat; aVelocityY: cfloat;
                                aVelocityZ: cfloat) {.cdecl,
    importc: "Soloud_set3dSourceVelocity", dynlib: libname.}
proc Soloud_set3dSourceMinMaxDistance*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                      aMinDistance: cfloat; aMaxDistance: cfloat) {.
    cdecl, importc: "Soloud_set3dSourceMinMaxDistance", dynlib: libname.}
proc Soloud_set3dSourceAttenuation*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                   aAttenuationModel: cuint;
                                   aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Soloud_set3dSourceAttenuation", dynlib: libname.}
proc Soloud_set3dSourceDopplerFactor*(aSoloud: ptr Soloud; aVoiceHandle: cuint;
                                     aDopplerFactor: cfloat) {.cdecl,
    importc: "Soloud_set3dSourceDopplerFactor", dynlib: libname.}
proc Soloud_mix*(aSoloud: ptr Soloud; aBuffer: ptr cfloat; aSamples: cuint) {.cdecl,
    importc: "Soloud_mix", dynlib: libname.}
proc Soloud_mixSigned16*(aSoloud: ptr Soloud; aBuffer: ptr cshort; aSamples: cuint) {.
    cdecl, importc: "Soloud_mixSigned16", dynlib: libname.}
## 
##  AudioAttenuator
## 

proc AudioAttenuator_destroy*(aAudioAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "AudioAttenuator_destroy", dynlib: libname.}
proc AudioAttenuator_attenuate*(aAudioAttenuator: ptr AudioAttenuator;
                               aDistance: cfloat; aMinDistance: cfloat;
                               aMaxDistance: cfloat; aRolloffFactor: cfloat): cfloat {.
    cdecl, importc: "AudioAttenuator_attenuate", dynlib: libname.}
## 
##  BiquadResonantFilter
## 

proc BiquadResonantFilter_destroy*(aBiquadResonantFilter: ptr BiquadResonantFilter) {.
    cdecl, importc: "BiquadResonantFilter_destroy", dynlib: libname.}
proc BiquadResonantFilter_create*(): ptr BiquadResonantFilter {.cdecl,
    importc: "BiquadResonantFilter_create", dynlib: libname.}
proc BiquadResonantFilter_setParams*(aBiquadResonantFilter: ptr BiquadResonantFilter;
                                    aType: cint; aSampleRate: cfloat;
                                    aFrequency: cfloat; aResonance: cfloat): cint {.
    cdecl, importc: "BiquadResonantFilter_setParams", dynlib: libname.}
## 
##  LofiFilter
## 

proc LofiFilter_destroy*(aLofiFilter: ptr LofiFilter) {.cdecl,
    importc: "LofiFilter_destroy", dynlib: libname.}
proc LofiFilter_create*(): ptr LofiFilter {.cdecl, importc: "LofiFilter_create",
                                        dynlib: libname.}
proc LofiFilter_setParams*(aLofiFilter: ptr LofiFilter; aSampleRate: cfloat;
                          aBitdepth: cfloat): cint {.cdecl,
    importc: "LofiFilter_setParams", dynlib: libname.}
## 
##  Bus
## 

proc Bus_destroy*(aBus: ptr Bus) {.cdecl, importc: "Bus_destroy", dynlib: libname.}
proc Bus_create*(): ptr Bus {.cdecl, importc: "Bus_create", dynlib: libname.}
proc Bus_setFilter*(aBus: ptr Bus; aFilterId: cuint; aFilter: ptr Filter) {.cdecl,
    importc: "Bus_setFilter", dynlib: libname.}
proc Bus_play*(aBus: ptr Bus; aSound: ptr AudioSource): cuint {.cdecl,
    importc: "Bus_play", dynlib: libname.}
proc Bus_playEx*(aBus: ptr Bus; aSound: ptr AudioSource; aVolume: cfloat; ##  = 1.0f
                aPan: cfloat;  ##  = 0.0f
                aPaused: cint): cuint {.cdecl, importc: "Bus_playEx", dynlib: libname.}
  ##  = 0
proc Bus_playClocked*(aBus: ptr Bus; aSoundTime: cdouble; aSound: ptr AudioSource): cuint {.
    cdecl, importc: "Bus_playClocked", dynlib: libname.}
proc Bus_playClockedEx*(aBus: ptr Bus; aSoundTime: cdouble; aSound: ptr AudioSource; aVolume: cfloat; ##  = 1.0f
                       aPan: cfloat): cuint {.cdecl, importc: "Bus_playClockedEx",
    dynlib: libname.}
  ##  = 0.0f
proc Bus_play3d*(aBus: ptr Bus; aSound: ptr AudioSource; aPosX: cfloat; aPosY: cfloat;
                aPosZ: cfloat): cuint {.cdecl, importc: "Bus_play3d", dynlib: libname.}
proc Bus_play3dEx*(aBus: ptr Bus; aSound: ptr AudioSource; aPosX: cfloat; aPosY: cfloat;
                  aPosZ: cfloat; aVelX: cfloat; ##  = 0.0f
                  aVelY: cfloat; ##  = 0.0f
                  aVelZ: cfloat; ##  = 0.0f
                  aVolume: cfloat; ##  = 1.0f
                  aPaused: cint): cuint {.cdecl, importc: "Bus_play3dEx",
                                       dynlib: libname.}
  ##  = 0
proc Bus_play3dClocked*(aBus: ptr Bus; aSoundTime: cdouble; aSound: ptr AudioSource;
                       aPosX: cfloat; aPosY: cfloat; aPosZ: cfloat): cuint {.cdecl,
    importc: "Bus_play3dClocked", dynlib: libname.}
proc Bus_play3dClockedEx*(aBus: ptr Bus; aSoundTime: cdouble; aSound: ptr AudioSource;
                         aPosX: cfloat; aPosY: cfloat; aPosZ: cfloat; aVelX: cfloat; ##  = 0.0f
                         aVelY: cfloat; ##  = 0.0f
                         aVelZ: cfloat; ##  = 0.0f
                         aVolume: cfloat): cuint {.cdecl,
    importc: "Bus_play3dClockedEx", dynlib: libname.}
  ##  = 1.0f
proc Bus_setChannels*(aBus: ptr Bus; aChannels: cuint): cint {.cdecl,
    importc: "Bus_setChannels", dynlib: libname.}
proc Bus_setVisualizationEnable*(aBus: ptr Bus; aEnable: cint) {.cdecl,
    importc: "Bus_setVisualizationEnable", dynlib: libname.}
proc Bus_calcFFT*(aBus: ptr Bus): ptr cfloat {.cdecl, importc: "Bus_calcFFT",
    dynlib: libname.}
proc Bus_getWave*(aBus: ptr Bus): ptr cfloat {.cdecl, importc: "Bus_getWave",
    dynlib: libname.}
proc Bus_setVolume*(aBus: ptr Bus; aVolume: cfloat) {.cdecl, importc: "Bus_setVolume",
    dynlib: libname.}
proc Bus_setLooping*(aBus: ptr Bus; aLoop: cint) {.cdecl, importc: "Bus_setLooping",
    dynlib: libname.}
proc Bus_set3dMinMaxDistance*(aBus: ptr Bus; aMinDistance: cfloat;
                             aMaxDistance: cfloat) {.cdecl,
    importc: "Bus_set3dMinMaxDistance", dynlib: libname.}
proc Bus_set3dAttenuation*(aBus: ptr Bus; aAttenuationModel: cuint;
                          aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Bus_set3dAttenuation", dynlib: libname.}
proc Bus_set3dDopplerFactor*(aBus: ptr Bus; aDopplerFactor: cfloat) {.cdecl,
    importc: "Bus_set3dDopplerFactor", dynlib: libname.}
proc Bus_set3dProcessing*(aBus: ptr Bus; aDo3dProcessing: cint) {.cdecl,
    importc: "Bus_set3dProcessing", dynlib: libname.}
proc Bus_set3dListenerRelative*(aBus: ptr Bus; aListenerRelative: cint) {.cdecl,
    importc: "Bus_set3dListenerRelative", dynlib: libname.}
proc Bus_set3dDistanceDelay*(aBus: ptr Bus; aDistanceDelay: cint) {.cdecl,
    importc: "Bus_set3dDistanceDelay", dynlib: libname.}
proc Bus_set3dCollider*(aBus: ptr Bus; aCollider: ptr AudioCollider) {.cdecl,
    importc: "Bus_set3dCollider", dynlib: libname.}
proc Bus_set3dColliderEx*(aBus: ptr Bus; aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "Bus_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc Bus_set3dAttenuator*(aBus: ptr Bus; aAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "Bus_set3dAttenuator", dynlib: libname.}
proc Bus_setInaudibleBehavior*(aBus: ptr Bus; aMustTick: cint; aKill: cint) {.cdecl,
    importc: "Bus_setInaudibleBehavior", dynlib: libname.}
proc Bus_stop*(aBus: ptr Bus) {.cdecl, importc: "Bus_stop", dynlib: libname.}
## 
##  EchoFilter
## 

proc EchoFilter_destroy*(aEchoFilter: ptr EchoFilter) {.cdecl,
    importc: "EchoFilter_destroy", dynlib: libname.}
proc EchoFilter_create*(): ptr EchoFilter {.cdecl, importc: "EchoFilter_create",
                                        dynlib: libname.}
proc EchoFilter_setParams*(aEchoFilter: ptr EchoFilter; aDelay: cfloat): cint {.cdecl,
    importc: "EchoFilter_setParams", dynlib: libname.}
proc EchoFilter_setParamsEx*(aEchoFilter: ptr EchoFilter; aDelay: cfloat; aDecay: cfloat; ##  = 0.7f
                            aFilter: cfloat): cint {.cdecl,
    importc: "EchoFilter_setParamsEx", dynlib: libname.}
  ##  = 0.0f
## 
##  FFTFilter
## 

proc FFTFilter_destroy*(aFFTFilter: ptr FFTFilter) {.cdecl,
    importc: "FFTFilter_destroy", dynlib: libname.}
proc FFTFilter_create*(): ptr FFTFilter {.cdecl, importc: "FFTFilter_create",
                                      dynlib: libname.}
## 
##  BassboostFilter
## 

proc BassboostFilter_destroy*(aBassboostFilter: ptr BassboostFilter) {.cdecl,
    importc: "BassboostFilter_destroy", dynlib: libname.}
proc BassboostFilter_setParams*(aBassboostFilter: ptr BassboostFilter;
                               aBoost: cfloat): cint {.cdecl,
    importc: "BassboostFilter_setParams", dynlib: libname.}
proc BassboostFilter_create*(): ptr BassboostFilter {.cdecl,
    importc: "BassboostFilter_create", dynlib: libname.}
## 
##  Speech
## 

proc Speech_destroy*(aSpeech: ptr Speech) {.cdecl, importc: "Speech_destroy",
                                        dynlib: libname.}
proc Speech_create*(): ptr Speech {.cdecl, importc: "Speech_create", dynlib: libname.}
proc Speech_setText*(aSpeech: ptr Speech; aText: cstring): cint {.cdecl,
    importc: "Speech_setText", dynlib: libname.}
proc Speech_setVolume*(aSpeech: ptr Speech; aVolume: cfloat) {.cdecl,
    importc: "Speech_setVolume", dynlib: libname.}
proc Speech_setLooping*(aSpeech: ptr Speech; aLoop: cint) {.cdecl,
    importc: "Speech_setLooping", dynlib: libname.}
proc Speech_set3dMinMaxDistance*(aSpeech: ptr Speech; aMinDistance: cfloat;
                                aMaxDistance: cfloat) {.cdecl,
    importc: "Speech_set3dMinMaxDistance", dynlib: libname.}
proc Speech_set3dAttenuation*(aSpeech: ptr Speech; aAttenuationModel: cuint;
                             aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Speech_set3dAttenuation", dynlib: libname.}
proc Speech_set3dDopplerFactor*(aSpeech: ptr Speech; aDopplerFactor: cfloat) {.cdecl,
    importc: "Speech_set3dDopplerFactor", dynlib: libname.}
proc Speech_set3dProcessing*(aSpeech: ptr Speech; aDo3dProcessing: cint) {.cdecl,
    importc: "Speech_set3dProcessing", dynlib: libname.}
proc Speech_set3dListenerRelative*(aSpeech: ptr Speech; aListenerRelative: cint) {.
    cdecl, importc: "Speech_set3dListenerRelative", dynlib: libname.}
proc Speech_set3dDistanceDelay*(aSpeech: ptr Speech; aDistanceDelay: cint) {.cdecl,
    importc: "Speech_set3dDistanceDelay", dynlib: libname.}
proc Speech_set3dCollider*(aSpeech: ptr Speech; aCollider: ptr AudioCollider) {.cdecl,
    importc: "Speech_set3dCollider", dynlib: libname.}
proc Speech_set3dColliderEx*(aSpeech: ptr Speech; aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "Speech_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc Speech_set3dAttenuator*(aSpeech: ptr Speech; aAttenuator: ptr AudioAttenuator) {.
    cdecl, importc: "Speech_set3dAttenuator", dynlib: libname.}
proc Speech_setInaudibleBehavior*(aSpeech: ptr Speech; aMustTick: cint; aKill: cint) {.
    cdecl, importc: "Speech_setInaudibleBehavior", dynlib: libname.}
proc Speech_setFilter*(aSpeech: ptr Speech; aFilterId: cuint; aFilter: ptr Filter) {.
    cdecl, importc: "Speech_setFilter", dynlib: libname.}
proc Speech_stop*(aSpeech: ptr Speech) {.cdecl, importc: "Speech_stop", dynlib: libname.}
## 
##  Wav
## 

proc Wav_destroy*(aWav: ptr Wav) {.cdecl, importc: "Wav_destroy", dynlib: libname.}
proc Wav_create*(): ptr Wav {.cdecl, importc: "Wav_create", dynlib: libname.}
proc Wav_load*(aWav: ptr Wav; aFilename: cstring): cint {.cdecl, importc: "Wav_load",
    dynlib: libname.}
proc Wav_loadMem*(aWav: ptr Wav; aMem: ptr cuchar; aLength: cuint): cint {.cdecl,
    importc: "Wav_loadMem", dynlib: libname.}
proc Wav_loadMemEx*(aWav: ptr Wav; aMem: ptr cuchar; aLength: cuint; aCopy: cint; ##  = false
                   aTakeOwnership: cint): cint {.cdecl, importc: "Wav_loadMemEx",
    dynlib: libname.}
  ##  = true
proc Wav_loadFile*(aWav: ptr Wav; aFile: ptr File): cint {.cdecl,
    importc: "Wav_loadFile", dynlib: libname.}
proc Wav_getLength*(aWav: ptr Wav): cdouble {.cdecl, importc: "Wav_getLength",
    dynlib: libname.}
proc Wav_setVolume*(aWav: ptr Wav; aVolume: cfloat) {.cdecl, importc: "Wav_setVolume",
    dynlib: libname.}
proc Wav_setLooping*(aWav: ptr Wav; aLoop: cint) {.cdecl, importc: "Wav_setLooping",
    dynlib: libname.}
proc Wav_set3dMinMaxDistance*(aWav: ptr Wav; aMinDistance: cfloat;
                             aMaxDistance: cfloat) {.cdecl,
    importc: "Wav_set3dMinMaxDistance", dynlib: libname.}
proc Wav_set3dAttenuation*(aWav: ptr Wav; aAttenuationModel: cuint;
                          aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Wav_set3dAttenuation", dynlib: libname.}
proc Wav_set3dDopplerFactor*(aWav: ptr Wav; aDopplerFactor: cfloat) {.cdecl,
    importc: "Wav_set3dDopplerFactor", dynlib: libname.}
proc Wav_set3dProcessing*(aWav: ptr Wav; aDo3dProcessing: cint) {.cdecl,
    importc: "Wav_set3dProcessing", dynlib: libname.}
proc Wav_set3dListenerRelative*(aWav: ptr Wav; aListenerRelative: cint) {.cdecl,
    importc: "Wav_set3dListenerRelative", dynlib: libname.}
proc Wav_set3dDistanceDelay*(aWav: ptr Wav; aDistanceDelay: cint) {.cdecl,
    importc: "Wav_set3dDistanceDelay", dynlib: libname.}
proc Wav_set3dCollider*(aWav: ptr Wav; aCollider: ptr AudioCollider) {.cdecl,
    importc: "Wav_set3dCollider", dynlib: libname.}
proc Wav_set3dColliderEx*(aWav: ptr Wav; aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "Wav_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc Wav_set3dAttenuator*(aWav: ptr Wav; aAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "Wav_set3dAttenuator", dynlib: libname.}
proc Wav_setInaudibleBehavior*(aWav: ptr Wav; aMustTick: cint; aKill: cint) {.cdecl,
    importc: "Wav_setInaudibleBehavior", dynlib: libname.}
proc Wav_setFilter*(aWav: ptr Wav; aFilterId: cuint; aFilter: ptr Filter) {.cdecl,
    importc: "Wav_setFilter", dynlib: libname.}
proc Wav_stop*(aWav: ptr Wav) {.cdecl, importc: "Wav_stop", dynlib: libname.}
## 
##  WavStream
## 

proc WavStream_destroy*(aWavStream: ptr WavStream) {.cdecl,
    importc: "WavStream_destroy", dynlib: libname.}
proc WavStream_create*(): ptr WavStream {.cdecl, importc: "WavStream_create",
                                      dynlib: libname.}
proc WavStream_load*(aWavStream: ptr WavStream; aFilename: cstring): cint {.cdecl,
    importc: "WavStream_load", dynlib: libname.}
proc WavStream_loadMem*(aWavStream: ptr WavStream; aData: ptr cuchar; aDataLen: cuint): cint {.
    cdecl, importc: "WavStream_loadMem", dynlib: libname.}
proc WavStream_loadMemEx*(aWavStream: ptr WavStream; aData: ptr cuchar;
                         aDataLen: cuint; aCopy: cint; ##  = false
                         aTakeOwnership: cint): cint {.cdecl,
    importc: "WavStream_loadMemEx", dynlib: libname.}
  ##  = true
proc WavStream_loadToMem*(aWavStream: ptr WavStream; aFilename: cstring): cint {.cdecl,
    importc: "WavStream_loadToMem", dynlib: libname.}
proc WavStream_loadFile*(aWavStream: ptr WavStream; aFile: ptr File): cint {.cdecl,
    importc: "WavStream_loadFile", dynlib: libname.}
proc WavStream_loadFileToMem*(aWavStream: ptr WavStream; aFile: ptr File): cint {.cdecl,
    importc: "WavStream_loadFileToMem", dynlib: libname.}
proc WavStream_getLength*(aWavStream: ptr WavStream): cdouble {.cdecl,
    importc: "WavStream_getLength", dynlib: libname.}
proc WavStream_setVolume*(aWavStream: ptr WavStream; aVolume: cfloat) {.cdecl,
    importc: "WavStream_setVolume", dynlib: libname.}
proc WavStream_setLooping*(aWavStream: ptr WavStream; aLoop: cint) {.cdecl,
    importc: "WavStream_setLooping", dynlib: libname.}
proc WavStream_set3dMinMaxDistance*(aWavStream: ptr WavStream; aMinDistance: cfloat;
                                   aMaxDistance: cfloat) {.cdecl,
    importc: "WavStream_set3dMinMaxDistance", dynlib: libname.}
proc WavStream_set3dAttenuation*(aWavStream: ptr WavStream;
                                aAttenuationModel: cuint;
                                aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "WavStream_set3dAttenuation", dynlib: libname.}
proc WavStream_set3dDopplerFactor*(aWavStream: ptr WavStream; aDopplerFactor: cfloat) {.
    cdecl, importc: "WavStream_set3dDopplerFactor", dynlib: libname.}
proc WavStream_set3dProcessing*(aWavStream: ptr WavStream; aDo3dProcessing: cint) {.
    cdecl, importc: "WavStream_set3dProcessing", dynlib: libname.}
proc WavStream_set3dListenerRelative*(aWavStream: ptr WavStream;
                                     aListenerRelative: cint) {.cdecl,
    importc: "WavStream_set3dListenerRelative", dynlib: libname.}
proc WavStream_set3dDistanceDelay*(aWavStream: ptr WavStream; aDistanceDelay: cint) {.
    cdecl, importc: "WavStream_set3dDistanceDelay", dynlib: libname.}
proc WavStream_set3dCollider*(aWavStream: ptr WavStream;
                             aCollider: ptr AudioCollider) {.cdecl,
    importc: "WavStream_set3dCollider", dynlib: libname.}
proc WavStream_set3dColliderEx*(aWavStream: ptr WavStream;
                               aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "WavStream_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc WavStream_set3dAttenuator*(aWavStream: ptr WavStream;
                               aAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "WavStream_set3dAttenuator", dynlib: libname.}
proc WavStream_setInaudibleBehavior*(aWavStream: ptr WavStream; aMustTick: cint;
                                    aKill: cint) {.cdecl,
    importc: "WavStream_setInaudibleBehavior", dynlib: libname.}
proc WavStream_setFilter*(aWavStream: ptr WavStream; aFilterId: cuint;
                         aFilter: ptr Filter) {.cdecl,
    importc: "WavStream_setFilter", dynlib: libname.}
proc WavStream_stop*(aWavStream: ptr WavStream) {.cdecl, importc: "WavStream_stop",
    dynlib: libname.}
## 
##  Prg
## 

proc Prg_destroy*(aPrg: ptr Prg) {.cdecl, importc: "Prg_destroy", dynlib: libname.}
proc Prg_create*(): ptr Prg {.cdecl, importc: "Prg_create", dynlib: libname.}
proc Prg_rand*(aPrg: ptr Prg): cuint {.cdecl, importc: "Prg_rand", dynlib: libname.}
proc Prg_srand*(aPrg: ptr Prg; aSeed: cint) {.cdecl, importc: "Prg_srand",
                                        dynlib: libname.}
## 
##  Sfxr
## 

proc Sfxr_destroy*(aSfxr: ptr Sfxr) {.cdecl, importc: "Sfxr_destroy", dynlib: libname.}
proc Sfxr_create*(): ptr Sfxr {.cdecl, importc: "Sfxr_create", dynlib: libname.}
proc Sfxr_resetParams*(aSfxr: ptr Sfxr) {.cdecl, importc: "Sfxr_resetParams",
                                      dynlib: libname.}
proc Sfxr_loadParams*(aSfxr: ptr Sfxr; aFilename: cstring): cint {.cdecl,
    importc: "Sfxr_loadParams", dynlib: libname.}
proc Sfxr_loadParamsMem*(aSfxr: ptr Sfxr; aMem: ptr cuchar; aLength: cuint): cint {.cdecl,
    importc: "Sfxr_loadParamsMem", dynlib: libname.}
proc Sfxr_loadParamsMemEx*(aSfxr: ptr Sfxr; aMem: ptr cuchar; aLength: cuint; aCopy: cint; ##  = false
                          aTakeOwnership: cint): cint {.cdecl,
    importc: "Sfxr_loadParamsMemEx", dynlib: libname.}
  ##  = true
proc Sfxr_loadParamsFile*(aSfxr: ptr Sfxr; aFile: ptr File): cint {.cdecl,
    importc: "Sfxr_loadParamsFile", dynlib: libname.}
proc Sfxr_loadPreset*(aSfxr: ptr Sfxr; aPresetNo: cint; aRandSeed: cint): cint {.cdecl,
    importc: "Sfxr_loadPreset", dynlib: libname.}
proc Sfxr_setVolume*(aSfxr: ptr Sfxr; aVolume: cfloat) {.cdecl,
    importc: "Sfxr_setVolume", dynlib: libname.}
proc Sfxr_setLooping*(aSfxr: ptr Sfxr; aLoop: cint) {.cdecl,
    importc: "Sfxr_setLooping", dynlib: libname.}
proc Sfxr_set3dMinMaxDistance*(aSfxr: ptr Sfxr; aMinDistance: cfloat;
                              aMaxDistance: cfloat) {.cdecl,
    importc: "Sfxr_set3dMinMaxDistance", dynlib: libname.}
proc Sfxr_set3dAttenuation*(aSfxr: ptr Sfxr; aAttenuationModel: cuint;
                           aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Sfxr_set3dAttenuation", dynlib: libname.}
proc Sfxr_set3dDopplerFactor*(aSfxr: ptr Sfxr; aDopplerFactor: cfloat) {.cdecl,
    importc: "Sfxr_set3dDopplerFactor", dynlib: libname.}
proc Sfxr_set3dProcessing*(aSfxr: ptr Sfxr; aDo3dProcessing: cint) {.cdecl,
    importc: "Sfxr_set3dProcessing", dynlib: libname.}
proc Sfxr_set3dListenerRelative*(aSfxr: ptr Sfxr; aListenerRelative: cint) {.cdecl,
    importc: "Sfxr_set3dListenerRelative", dynlib: libname.}
proc Sfxr_set3dDistanceDelay*(aSfxr: ptr Sfxr; aDistanceDelay: cint) {.cdecl,
    importc: "Sfxr_set3dDistanceDelay", dynlib: libname.}
proc Sfxr_set3dCollider*(aSfxr: ptr Sfxr; aCollider: ptr AudioCollider) {.cdecl,
    importc: "Sfxr_set3dCollider", dynlib: libname.}
proc Sfxr_set3dColliderEx*(aSfxr: ptr Sfxr; aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "Sfxr_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc Sfxr_set3dAttenuator*(aSfxr: ptr Sfxr; aAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "Sfxr_set3dAttenuator", dynlib: libname.}
proc Sfxr_setInaudibleBehavior*(aSfxr: ptr Sfxr; aMustTick: cint; aKill: cint) {.cdecl,
    importc: "Sfxr_setInaudibleBehavior", dynlib: libname.}
proc Sfxr_setFilter*(aSfxr: ptr Sfxr; aFilterId: cuint; aFilter: ptr Filter) {.cdecl,
    importc: "Sfxr_setFilter", dynlib: libname.}
proc Sfxr_stop*(aSfxr: ptr Sfxr) {.cdecl, importc: "Sfxr_stop", dynlib: libname.}
## 
##  FlangerFilter
## 

proc FlangerFilter_destroy*(aFlangerFilter: ptr FlangerFilter) {.cdecl,
    importc: "FlangerFilter_destroy", dynlib: libname.}
proc FlangerFilter_create*(): ptr FlangerFilter {.cdecl,
    importc: "FlangerFilter_create", dynlib: libname.}
proc FlangerFilter_setParams*(aFlangerFilter: ptr FlangerFilter; aDelay: cfloat;
                             aFreq: cfloat): cint {.cdecl,
    importc: "FlangerFilter_setParams", dynlib: libname.}
## 
##  DCRemovalFilter
## 

proc DCRemovalFilter_destroy*(aDCRemovalFilter: ptr DCRemovalFilter) {.cdecl,
    importc: "DCRemovalFilter_destroy", dynlib: libname.}
proc DCRemovalFilter_create*(): ptr DCRemovalFilter {.cdecl,
    importc: "DCRemovalFilter_create", dynlib: libname.}
proc DCRemovalFilter_setParams*(aDCRemovalFilter: ptr DCRemovalFilter): cint {.cdecl,
    importc: "DCRemovalFilter_setParams", dynlib: libname.}
proc DCRemovalFilter_setParamsEx*(aDCRemovalFilter: ptr DCRemovalFilter; aLength: cfloat): cint {.
    cdecl, importc: "DCRemovalFilter_setParamsEx", dynlib: libname.}
  ##  = 0.1f
## 
##  Openmpt
## 

proc Openmpt_destroy*(aOpenmpt: ptr Openmpt) {.cdecl, importc: "Openmpt_destroy",
    dynlib: libname.}
proc Openmpt_create*(): ptr Openmpt {.cdecl, importc: "Openmpt_create", dynlib: libname.}
proc Openmpt_load*(aOpenmpt: ptr Openmpt; aFilename: cstring): cint {.cdecl,
    importc: "Openmpt_load", dynlib: libname.}
proc Openmpt_loadMem*(aOpenmpt: ptr Openmpt; aMem: ptr cuchar; aLength: cuint): cint {.
    cdecl, importc: "Openmpt_loadMem", dynlib: libname.}
proc Openmpt_loadMemEx*(aOpenmpt: ptr Openmpt; aMem: ptr cuchar; aLength: cuint; aCopy: cint; ##  = false
                       aTakeOwnership: cint): cint {.cdecl,
    importc: "Openmpt_loadMemEx", dynlib: libname.}
  ##  = true
proc Openmpt_loadFile*(aOpenmpt: ptr Openmpt; aFile: ptr File): cint {.cdecl,
    importc: "Openmpt_loadFile", dynlib: libname.}
proc Openmpt_setVolume*(aOpenmpt: ptr Openmpt; aVolume: cfloat) {.cdecl,
    importc: "Openmpt_setVolume", dynlib: libname.}
proc Openmpt_setLooping*(aOpenmpt: ptr Openmpt; aLoop: cint) {.cdecl,
    importc: "Openmpt_setLooping", dynlib: libname.}
proc Openmpt_set3dMinMaxDistance*(aOpenmpt: ptr Openmpt; aMinDistance: cfloat;
                                 aMaxDistance: cfloat) {.cdecl,
    importc: "Openmpt_set3dMinMaxDistance", dynlib: libname.}
proc Openmpt_set3dAttenuation*(aOpenmpt: ptr Openmpt; aAttenuationModel: cuint;
                              aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Openmpt_set3dAttenuation", dynlib: libname.}
proc Openmpt_set3dDopplerFactor*(aOpenmpt: ptr Openmpt; aDopplerFactor: cfloat) {.
    cdecl, importc: "Openmpt_set3dDopplerFactor", dynlib: libname.}
proc Openmpt_set3dProcessing*(aOpenmpt: ptr Openmpt; aDo3dProcessing: cint) {.cdecl,
    importc: "Openmpt_set3dProcessing", dynlib: libname.}
proc Openmpt_set3dListenerRelative*(aOpenmpt: ptr Openmpt; aListenerRelative: cint) {.
    cdecl, importc: "Openmpt_set3dListenerRelative", dynlib: libname.}
proc Openmpt_set3dDistanceDelay*(aOpenmpt: ptr Openmpt; aDistanceDelay: cint) {.cdecl,
    importc: "Openmpt_set3dDistanceDelay", dynlib: libname.}
proc Openmpt_set3dCollider*(aOpenmpt: ptr Openmpt; aCollider: ptr AudioCollider) {.
    cdecl, importc: "Openmpt_set3dCollider", dynlib: libname.}
proc Openmpt_set3dColliderEx*(aOpenmpt: ptr Openmpt; aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "Openmpt_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc Openmpt_set3dAttenuator*(aOpenmpt: ptr Openmpt;
                             aAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "Openmpt_set3dAttenuator", dynlib: libname.}
proc Openmpt_setInaudibleBehavior*(aOpenmpt: ptr Openmpt; aMustTick: cint; aKill: cint) {.
    cdecl, importc: "Openmpt_setInaudibleBehavior", dynlib: libname.}
proc Openmpt_setFilter*(aOpenmpt: ptr Openmpt; aFilterId: cuint; aFilter: ptr Filter) {.
    cdecl, importc: "Openmpt_setFilter", dynlib: libname.}
proc Openmpt_stop*(aOpenmpt: ptr Openmpt) {.cdecl, importc: "Openmpt_stop",
                                        dynlib: libname.}
## 
##  Monotone
## 

proc Monotone_destroy*(aMonotone: ptr Monotone) {.cdecl, importc: "Monotone_destroy",
    dynlib: libname.}
proc Monotone_create*(): ptr Monotone {.cdecl, importc: "Monotone_create",
                                    dynlib: libname.}
proc Monotone_setParams*(aMonotone: ptr Monotone; aHardwareChannels: cint): cint {.
    cdecl, importc: "Monotone_setParams", dynlib: libname.}
proc Monotone_setParamsEx*(aMonotone: ptr Monotone; aHardwareChannels: cint; aWaveform: cint): cint {.
    cdecl, importc: "Monotone_setParamsEx", dynlib: libname.}
  ##  = SQUARE
proc Monotone_load*(aMonotone: ptr Monotone; aFilename: cstring): cint {.cdecl,
    importc: "Monotone_load", dynlib: libname.}
proc Monotone_loadMem*(aMonotone: ptr Monotone; aMem: ptr cuchar; aLength: cuint): cint {.
    cdecl, importc: "Monotone_loadMem", dynlib: libname.}
proc Monotone_loadMemEx*(aMonotone: ptr Monotone; aMem: ptr cuchar; aLength: cuint; aCopy: cint; ##  = false
                        aTakeOwnership: cint): cint {.cdecl,
    importc: "Monotone_loadMemEx", dynlib: libname.}
  ##  = true
proc Monotone_loadFile*(aMonotone: ptr Monotone; aFile: ptr File): cint {.cdecl,
    importc: "Monotone_loadFile", dynlib: libname.}
proc Monotone_setVolume*(aMonotone: ptr Monotone; aVolume: cfloat) {.cdecl,
    importc: "Monotone_setVolume", dynlib: libname.}
proc Monotone_setLooping*(aMonotone: ptr Monotone; aLoop: cint) {.cdecl,
    importc: "Monotone_setLooping", dynlib: libname.}
proc Monotone_set3dMinMaxDistance*(aMonotone: ptr Monotone; aMinDistance: cfloat;
                                  aMaxDistance: cfloat) {.cdecl,
    importc: "Monotone_set3dMinMaxDistance", dynlib: libname.}
proc Monotone_set3dAttenuation*(aMonotone: ptr Monotone; aAttenuationModel: cuint;
                               aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "Monotone_set3dAttenuation", dynlib: libname.}
proc Monotone_set3dDopplerFactor*(aMonotone: ptr Monotone; aDopplerFactor: cfloat) {.
    cdecl, importc: "Monotone_set3dDopplerFactor", dynlib: libname.}
proc Monotone_set3dProcessing*(aMonotone: ptr Monotone; aDo3dProcessing: cint) {.
    cdecl, importc: "Monotone_set3dProcessing", dynlib: libname.}
proc Monotone_set3dListenerRelative*(aMonotone: ptr Monotone;
                                    aListenerRelative: cint) {.cdecl,
    importc: "Monotone_set3dListenerRelative", dynlib: libname.}
proc Monotone_set3dDistanceDelay*(aMonotone: ptr Monotone; aDistanceDelay: cint) {.
    cdecl, importc: "Monotone_set3dDistanceDelay", dynlib: libname.}
proc Monotone_set3dCollider*(aMonotone: ptr Monotone; aCollider: ptr AudioCollider) {.
    cdecl, importc: "Monotone_set3dCollider", dynlib: libname.}
proc Monotone_set3dColliderEx*(aMonotone: ptr Monotone;
                              aCollider: ptr AudioCollider; aUserData: cint) {.cdecl,
    importc: "Monotone_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc Monotone_set3dAttenuator*(aMonotone: ptr Monotone;
                              aAttenuator: ptr AudioAttenuator) {.cdecl,
    importc: "Monotone_set3dAttenuator", dynlib: libname.}
proc Monotone_setInaudibleBehavior*(aMonotone: ptr Monotone; aMustTick: cint;
                                   aKill: cint) {.cdecl,
    importc: "Monotone_setInaudibleBehavior", dynlib: libname.}
proc Monotone_setFilter*(aMonotone: ptr Monotone; aFilterId: cuint;
                        aFilter: ptr Filter) {.cdecl, importc: "Monotone_setFilter",
    dynlib: libname.}
proc Monotone_stop*(aMonotone: ptr Monotone) {.cdecl, importc: "Monotone_stop",
    dynlib: libname.}
## 
##  TedSid
## 

proc TedSid_destroy*(aTedSid: ptr TedSid) {.cdecl, importc: "TedSid_destroy",
                                        dynlib: libname.}
proc TedSid_create*(): ptr TedSid {.cdecl, importc: "TedSid_create", dynlib: libname.}
proc TedSid_load*(aTedSid: ptr TedSid; aFilename: cstring): cint {.cdecl,
    importc: "TedSid_load", dynlib: libname.}
proc TedSid_loadToMem*(aTedSid: ptr TedSid; aFilename: cstring): cint {.cdecl,
    importc: "TedSid_loadToMem", dynlib: libname.}
proc TedSid_loadMem*(aTedSid: ptr TedSid; aMem: ptr cuchar; aLength: cuint): cint {.cdecl,
    importc: "TedSid_loadMem", dynlib: libname.}
proc TedSid_loadMemEx*(aTedSid: ptr TedSid; aMem: ptr cuchar; aLength: cuint; aCopy: cint; ##  = false
                      aTakeOwnership: cint): cint {.cdecl,
    importc: "TedSid_loadMemEx", dynlib: libname.}
  ##  = true
proc TedSid_loadFileToMem*(aTedSid: ptr TedSid; aFile: ptr File): cint {.cdecl,
    importc: "TedSid_loadFileToMem", dynlib: libname.}
proc TedSid_loadFile*(aTedSid: ptr TedSid; aFile: ptr File): cint {.cdecl,
    importc: "TedSid_loadFile", dynlib: libname.}
proc TedSid_setVolume*(aTedSid: ptr TedSid; aVolume: cfloat) {.cdecl,
    importc: "TedSid_setVolume", dynlib: libname.}
proc TedSid_setLooping*(aTedSid: ptr TedSid; aLoop: cint) {.cdecl,
    importc: "TedSid_setLooping", dynlib: libname.}
proc TedSid_set3dMinMaxDistance*(aTedSid: ptr TedSid; aMinDistance: cfloat;
                                aMaxDistance: cfloat) {.cdecl,
    importc: "TedSid_set3dMinMaxDistance", dynlib: libname.}
proc TedSid_set3dAttenuation*(aTedSid: ptr TedSid; aAttenuationModel: cuint;
                             aAttenuationRolloffFactor: cfloat) {.cdecl,
    importc: "TedSid_set3dAttenuation", dynlib: libname.}
proc TedSid_set3dDopplerFactor*(aTedSid: ptr TedSid; aDopplerFactor: cfloat) {.cdecl,
    importc: "TedSid_set3dDopplerFactor", dynlib: libname.}
proc TedSid_set3dProcessing*(aTedSid: ptr TedSid; aDo3dProcessing: cint) {.cdecl,
    importc: "TedSid_set3dProcessing", dynlib: libname.}
proc TedSid_set3dListenerRelative*(aTedSid: ptr TedSid; aListenerRelative: cint) {.
    cdecl, importc: "TedSid_set3dListenerRelative", dynlib: libname.}
proc TedSid_set3dDistanceDelay*(aTedSid: ptr TedSid; aDistanceDelay: cint) {.cdecl,
    importc: "TedSid_set3dDistanceDelay", dynlib: libname.}
proc TedSid_set3dCollider*(aTedSid: ptr TedSid; aCollider: ptr AudioCollider) {.cdecl,
    importc: "TedSid_set3dCollider", dynlib: libname.}
proc TedSid_set3dColliderEx*(aTedSid: ptr TedSid; aCollider: ptr AudioCollider; aUserData: cint) {.
    cdecl, importc: "TedSid_set3dColliderEx", dynlib: libname.}
  ##  = 0
proc TedSid_set3dAttenuator*(aTedSid: ptr TedSid; aAttenuator: ptr AudioAttenuator) {.
    cdecl, importc: "TedSid_set3dAttenuator", dynlib: libname.}
proc TedSid_setInaudibleBehavior*(aTedSid: ptr TedSid; aMustTick: cint; aKill: cint) {.
    cdecl, importc: "TedSid_setInaudibleBehavior", dynlib: libname.}
proc TedSid_setFilter*(aTedSid: ptr TedSid; aFilterId: cuint; aFilter: ptr Filter) {.
    cdecl, importc: "TedSid_setFilter", dynlib: libname.}
proc TedSid_stop*(aTedSid: ptr TedSid) {.cdecl, importc: "TedSid_stop", dynlib: libname.}