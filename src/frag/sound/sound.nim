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

when defined(js):
  import jsffi, jsconsole

  proc newSoundFromMediaElement*(me: JsObject): asset.Sound =
    result = asset.Sound(assetType: AssetType.Sound)
    result.media = me
    result.snd = newSoundWithMediaElement(cast[MediaElement](me))
    console.log(result.snd)

proc load*(filepath: string): asset.Sound =  
  result = asset.Sound(assetType: AssetType.Sound)
  result.snd = newSoundWithFile(filepath)

proc loop*(sound: asset.Sound, loop: bool) =
  sound.snd.setLooping(loop)

proc play*(sound: asset.Sound) =
  when defined(js):
    sound.media.play()
  else:
    sound.snd.play()

proc stop*(sound: asset.Sound) =
  sound.snd.stop()

proc setGain*(sound: asset.Sound, gain: float) =
  sound.snd.`gain=`(gain)