local context = G.botContext

context.getSoundChannel = function()
  if not g_sounds then
    return
  end
  return g_sounds.getChannel(SoundChannels.Bot)
end

context.playSound = function(file)
  if g_sounds then
    pcall(function()
      if g_sounds.setAudioEnabled then
        g_sounds.setAudioEnabled(true)
      end
      if g_sounds.enableAudio then
        g_sounds.enableAudio()
      end
    end)
  end

  local botSoundChannel = context.getSoundChannel()
  if not botSoundChannel then
    return
  end

  botSoundChannel:setEnabled(true)
  pcall(function() botSoundChannel:setGain(1.0) end)
  botSoundChannel:stop(0)

  if not g_resources.fileExists(file) then
    if g_resources.fileExists("/sounds/alarm.ogg") then
      file = "/sounds/alarm.ogg"
    elseif g_resources.fileExists("/sounds/magnum.ogg") then
      file = "/sounds/magnum.ogg"
    elseif g_resources.fileExists("/client/sounds/startup.ogg") then
      file = "/client/sounds/startup.ogg"
    end
  end

  pcall(function()
    botSoundChannel:play(file, 0, 1.0)
  end)
  return botSoundChannel
end

context.stopSound = function()
  local botSoundChannel = context.getSoundChannel()
  if not botSoundChannel then
    return
  end
  botSoundChannel:stop()
end

context.playAlarm = function()
  return context.playSound("/sounds/alarm.ogg")
end
