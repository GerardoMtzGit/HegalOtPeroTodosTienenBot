setDefaultTab("Main")

local panelName = "alarms"
local ui = setupUI([[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Alarms')

  Button
    id: alerts
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Edit

]])
ui:setId(panelName)

if not storage[panelName] then
  storage[panelName] = {}
end

local config = storage[panelName]

ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
end

local window = UI.createWindow("AlarmsWindow")
window:hide()

ui.alerts.onClick = function()
  window:show()
  window:raise()
  window:focus()
end

local widgets = 
{
  "AlarmCheckBox", 
  "AlarmCheckBoxAndSpinBox", 
  "AlarmCheckBoxAndTextEdit"
}

local parents = 
{
  window.list, 
  window.settingsList
}

-- type
addAlarm = function(id, title, defaultValue, alarmType, parent, tooltip)
  local widget = UI.createWidget(widgets[alarmType], parents[parent])
  widget:setId(id)

  if type(config[id]) ~= 'table' then
    config[id] = {}
  end

  if type(config[id].enabled) == 'nil' then
    if alarmType == 1 then
      config[id].enabled = defaultValue
    else
      config[id].enabled = false
    end
  end

  widget.tick:setText(title)
  widget.tick:setChecked(config[id].enabled)
  if tooltip then
    widget.tick:setTooltip(tooltip)
  end
  widget.tick.onClick = function()
    config[id].enabled = not config[id].enabled
    widget.tick:setChecked(config[id].enabled)
  end

  if alarmType > 1 and type(config[id].value) == 'nil' then
    config[id].value = defaultValue
  end

  if alarmType == 2 then
    widget.value:setValue(config[id].value or defaultValue)
    widget.value.onValueChange = function(widget, value)
      config[id].value = value
    end
  elseif alarmType == 3 then
    widget.text:setText(config[id].value or defaultValue or "")
    widget.text.onTextChange = function(widget, newText)
      config[id].value = newText
    end
  end
end

-- settings
addAlarm("ignoreFriends", "Ignore Friends", true, 1, 2)
addAlarm("flashClient", "Flash Client", true, 1, 2)

-- alarm list
addAlarm("damageTaken", "Damage Taken", false, 1, 1)
addAlarm("lowHealth", "Low Health", 20, 2, 1)
addAlarm("lowMana", "Low Mana", 20, 2, 1)
addAlarm("playerAttack", "Player Attack", false, 1, 1)

UI.Separator(window.list)

addAlarm("privateMsg", "Private Message", false, 1, 1)
addAlarm("defaultMsg", "Default Message", false, 1, 1)
addAlarm("customMessage", "Custom Message:", "", 3, 1, "You can add text, that if found in any incoming message will trigger alert.\n You can add many, just separate them by comma.")

UI.Separator(window.list)

addAlarm("creatureDetected", "Creature Detected", false, 1, 1)
addAlarm("playerDetected", "Player Detected", false, 1, 1)
addAlarm("creatureName", "Creature Name:", "", 3, 1, "You can add a name or part of it, that if found in any visible creature name will trigger alert.\nYou can add many, just separate them by comma.")


local lastCall = now
local function alarm(file, windowText)
  if now - lastCall < 2000 then return end -- 2s delay
  lastCall = now

  if not g_resources.fileExists(file) then
    if g_resources.fileExists("/sounds/alarm.ogg") then
      file = "/sounds/alarm.ogg"
    elseif g_resources.fileExists("/sounds/magnum.ogg") then
      file = "/sounds/magnum.ogg"
    end
    lastCall = now + 4000 -- alarm.ogg length is 6s
  end

  pcall(function()
    if g_window and g_window.flash and config.flashClient and config.flashClient.enabled then
      g_window.flash()
    end
  end)

  pcall(function()
    local pName = player and player:getName() or "Player"
    g_window.setTitle(pName .. " - " .. (windowText or "Alarm!"))
  end)

  pcall(function()
    playSound(file)
  end)

  pcall(function()
    if modules.game_textmessage and modules.game_textmessage.displayFailureMessage then
      modules.game_textmessage.displayFailureMessage("[ALARM] " .. (windowText or "Alert!"))
    end
  end)
end

-- damage taken & custom message
onTextMessage(function(mode, text)
  if not config.enabled then return end
  if mode == 22 and config.damageTaken and config.damageTaken.enabled then
    return alarm('/sounds/magnum.ogg', "Damage Received!")
  end

  if config.playerAttack and config.playerAttack.enabled and string.match(text, "hitpoints due to an attack") and not string.match(text, "hitpoints due to an attack by a ") then
    return alarm("/sounds/Player_Attack.ogg", "Player Attack!")
  end

  if config.customMessage and config.customMessage.enabled then
    local alertText = config.customMessage.value or ""
    if alertText:len() > 0 then
      text = text:lower()
      local parts = string.split(alertText, ",")

      for i=1,#parts do
        local part = parts[i]
        part = part:trim()
        part = part:lower()

        if part:len() > 0 and text:find(part) then
          return alarm('/sounds/magnum.ogg', "Special Message: " .. part)
        end
      end
    end
  end
end)

-- default & private message
onTalk(function(name, level, mode, text, channelId, pos)
  if not config.enabled then return end
  if player and name == player:getName() then return end -- ignore self messages
  if config.ignoreFriends and config.ignoreFriends.enabled and isFriend and isFriend(name) then return end -- ignore friends if enabled

  if mode == 1 and config.defaultMsg and config.defaultMsg.enabled then
    return alarm("/sounds/magnum.ogg", "Default Message: " .. name)
  end

  if mode == 4 and config.privateMsg and config.privateMsg.enabled then
    return alarm("/sounds/Private_Message.ogg", "Private Message: " .. name)
  end
end)

-- health, mana & spectators
macro(100, function() 
  if not config.enabled then return end
  if config.lowHealth and config.lowHealth.enabled then
    if hppercent() < (config.lowHealth.value or 20) then
      return alarm("/sounds/Low_Health.ogg", "Low Health! (" .. hppercent() .. "%)")
    end
  end

  if config.lowMana and config.lowMana.enabled then
    if manapercent() < (config.lowMana.value or 20) then
      return alarm("/sounds/Low_Mana.ogg", "Low Mana! (" .. manapercent() .. "%)")
    end
  end

  local myZ = posz()
  for i, spec in ipairs(getSpectators()) do
    if not spec:isLocalPlayer() and spec:getPosition().z == myZ and not (config.ignoreFriends and config.ignoreFriends.enabled and isFriend and isFriend(spec)) then

      if spec:isPlayer() then 
        if spec:isTimedSquareVisible() and config.playerAttack and config.playerAttack.enabled then
          return alarm("/sounds/Player_Attack.ogg", "Player Attack! (" .. spec:getName() .. ")")
        end
        if config.playerDetected and config.playerDetected.enabled then
          return alarm("/sounds/Player_Detected.ogg", "Player Detected! (" .. spec:getName() .. ")")
        end
      else
        if config.creatureDetected and config.creatureDetected.enabled then
          return alarm("/sounds/Creature_Detected.ogg", "Creature Detected! (" .. spec:getName() .. ")")
        end
      end

      if config.creatureName and config.creatureName.enabled and config.creatureName.value then
        local name = spec:getName():lower()
        local fragments = string.split(config.creatureName.value, ",")
        
        for j=1,#fragments do
          local frag = fragments[j]:trim():lower()

          if frag:len() > 0 and name:find(frag) then
            return alarm("/sounds/alarm.ogg", "Special Creature: " .. spec:getName())
          end
        end
      end
    end
  end
end)
