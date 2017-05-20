import
  sound.sound as snd

import
  ../assets/asset_types,
  ../assets/asset

export asset.Sound

when defined(android):
  import jnim, sdl2

  let act = cast[jobject](androidGetActivity())
  initSoundEngineWithActivity(act)

proc load*(filepath: string): asset.Sound =
  var s = asset.Sound(assetType: AssetType.Sound)
  when not defined(js):
    s.snd = newSoundWithFile(filepath)
  return s

proc loop*(sound: asset.Sound, loop: bool) =
  sound.snd.setLooping(loop)

proc play*(sound: asset.Sound) =
  sound.snd.play()

proc stop*(sound: asset.Sound) =
  sound.snd.stop()

proc setGain*(sound: asset.Sound, gain: float) =
  sound.snd.`gain=`(gain)