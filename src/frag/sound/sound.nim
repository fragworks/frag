import
  sound.sound as snd

import
  ../assets/asset_types,
  ../assets/asset

export asset.Sound

proc load*(filepath: string): asset.Sound =
  var s = asset.Sound(assetType: AssetType.Sound)
  s.snd = newSoundWithFile(filepath)
  return s

proc play*(sound: asset.Sound) =
  sound.snd.play()

proc setGain*(sound: asset.Sound, gain: float) =
  sound.snd.`gain=`(gain)