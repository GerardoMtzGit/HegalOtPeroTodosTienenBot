local standBySpells = false
local standByItems = false

local red = "#ff0800" -- "#ff0800" / #ea3c53 best
local blue = "#7ef9ff"

local PotionAliases = {
  [438] = {23373, 23374, 438}, -- Ultimate Mana Potion (23373) / Ultimate Spirit (23374)
  [23373] = {23373, 438},
  [23374] = {23374, 438},
  [144] = {238, 144},          -- Great Mana Potion
  [238] = {238, 144},
  [93]  = {237, 93},           -- Strong Mana Potion
  [237] = {237, 93},
  [56]  = {268, 56},           -- Mana Potion
  [268] = {268, 56},
  [379] = {7643, 379},         -- Ultimate Health Potion
  [7643] = {7643, 379},
  [625] = {23375, 625},        -- Supreme Health Potion
  [23375] = {23375, 625},
  [225] = {239, 225},          -- Great Health Potion
  [239] = {239, 225},
  [115] = {236, 115},          -- Strong Health Potion
  [236] = {236, 115},
  [50]  = {266, 50},           -- Health Potion
  [266] = {266, 50},
  [228] = {7642, 228},         -- Great Spirit Potion
  [7642] = {7642, 228},
}

local function resolveItem(itemId)
  if not itemId or itemId <= 0 then return nil, itemId end
  
  -- 1. Check direct item ID
  local it = findItem(itemId)
  if it then return it, itemId end

  if getInventoryItem then
    for slot = 1, 10 do
      local invItem = getInventoryItem(slot)
      if invItem and invItem:getId() == itemId then
        return invItem, itemId
      end
    end
  end

  -- 2. Check potion aliases if not found
  local candidates = PotionAliases[itemId]
  if candidates then
    for _, altId in ipairs(candidates) do
      it = findItem(altId)
      if it then return it, altId end
      if getInventoryItem then
        for slot = 1, 10 do
          local invItem = getInventoryItem(slot)
          if invItem and invItem:getId() == altId then
            return invItem, altId
          end
        end
      end
    end
  end

  local fallbackId = (candidates and candidates[1]) or itemId
  return nil, fallbackId
end

local function useHealItem(itemObj, itemId)
  local ok = false
  if itemObj then
    ok = pcall(function() g_game.useWith(itemObj, player) end)
  end
  if not ok and itemId and itemId > 0 then
    pcall(function() g_game.useInventoryItemWith(itemId, player) end)
  end
end

setDefaultTab("HP")
local healPanelName = "healbot"
local ui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('HealBot')

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  Button
    id: 1
    anchors.top: prev.bottom
    anchors.left: parent.left
    text: 1
    margin-right: 2
    margin-top: 4
    size: 17 17

  Button
    id: 2
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 2
    margin-left: 4
    size: 17 17
    
  Button
    id: 3
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 3
    margin-left: 4
    size: 17 17

  Button
    id: 4
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 4
    margin-left: 4
    size: 17 17 
    
  Button
    id: 5
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    text: 5
    margin-left: 4
    size: 17 17
    
  Label
    id: name
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: prev.right
    anchors.right: parent.right
    text-align: center
    margin-left: 4
    height: 17
    text: Profile #1
    background: #292A2A
]])
ui:setId(healPanelName)

if not HealBotConfig[healPanelName] or not HealBotConfig[healPanelName][1] or #HealBotConfig[healPanelName] ~= 5 then
  HealBotConfig[healPanelName] = {
    [1] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #1",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [2] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #2",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [3] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #3",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [4] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #4",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
    [5] = {
      enabled = false,
      spellTable = {},
      itemTable = {},
      name = "Profile #5",
      Visible = true,
      Cooldown = true,
      Interval = true,
      Conditions = true,
      Delay = true,
      MessageDelay = false
    },
  }
end

if not HealBotConfig.currentHealBotProfile or HealBotConfig.currentHealBotProfile == 0 or HealBotConfig.currentHealBotProfile > 5 then 
  HealBotConfig.currentHealBotProfile = 1
end

-- finding correct table, manual unfortunately
local currentSettings
local setActiveProfile = function()
  local n = HealBotConfig.currentHealBotProfile
  currentSettings = HealBotConfig[healPanelName][n]
end
setActiveProfile()

local activeProfileColor = function()
  for i=1,5 do
    if i == HealBotConfig.currentHealBotProfile then
      ui[i]:setColor("green")
    else
      ui[i]:setColor("white")
    end
  end
end
activeProfileColor()

ui.title:setOn(currentSettings.enabled)
ui.title.onClick = function(widget)
  currentSettings.enabled = not currentSettings.enabled
  widget:setOn(currentSettings.enabled)
  vBotConfigSave("heal")
end

ui.settings.onClick = function(widget)
  healWindow:show()
  healWindow:raise()
  healWindow:focus()
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
  healWindow = UI.createWindow('HealWindow', rootWidget)
  healWindow:hide()

  healWindow.onVisibilityChange = function(widget, visible)
    if not visible then
      vBotConfigSave("heal")
      healWindow.healer:show()
      healWindow.settings:hide()
      healWindow.settingsButton:setText("Settings")
    end
  end

  healWindow.settingsButton.onClick = function(widget)
    if healWindow.healer:isVisible() then
      healWindow.healer:hide()
      healWindow.settings:show()
      widget:setText("Back")
    else
      healWindow.healer:show()
      healWindow.settings:hide()
      widget:setText("Settings")
    end
  end

  local setProfileName = function()
    ui.name:setText(currentSettings.name)
  end
  healWindow.settings.profiles.Name.onTextChange = function(widget, text)
    currentSettings.name = text
    setProfileName()
  end
  healWindow.settings.list.Visible.onClick = function(widget)
    currentSettings.Visible = not currentSettings.Visible
    healWindow.settings.list.Visible:setChecked(currentSettings.Visible)
  end
  healWindow.settings.list.Cooldown.onClick = function(widget)
    currentSettings.Cooldown = not currentSettings.Cooldown
    healWindow.settings.list.Cooldown:setChecked(currentSettings.Cooldown)
  end
  healWindow.settings.list.Interval.onClick = function(widget)
    currentSettings.Interval = not currentSettings.Interval
    healWindow.settings.list.Interval:setChecked(currentSettings.Interval)
  end
  healWindow.settings.list.Conditions.onClick = function(widget)
    currentSettings.Conditions = not currentSettings.Conditions
    healWindow.settings.list.Conditions:setChecked(currentSettings.Conditions)
  end
  healWindow.settings.list.Delay.onClick = function(widget)
    currentSettings.Delay = not currentSettings.Delay
    healWindow.settings.list.Delay:setChecked(currentSettings.Delay)
  end
  healWindow.settings.list.MessageDelay.onClick = function(widget)
    currentSettings.MessageDelay = not currentSettings.MessageDelay
    healWindow.settings.list.MessageDelay:setChecked(currentSettings.MessageDelay)
  end

  local refreshSpells = function()
    if currentSettings.spellTable then
      healWindow.healer.spells.spellList:destroyChildren()
      for _, entry in pairs(currentSettings.spellTable) do
        local label = UI.createWidget("SpellEntry", healWindow.healer.spells.spellList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          standBySpells = false
          standByItems = false
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          standBySpells = false
          standByItems = false
          table.removevalue(currentSettings.spellTable, entry)
          reindexTable(currentSettings.spellTable)
          label:destroy()
        end
        label:setText("(MP>" .. entry.cost .. ") " .. entry.origin .. entry.sign .. entry.value .. ": " .. entry.spell)
      end
    end
  end
  refreshSpells()

  local refreshItems = function()
    if currentSettings.itemTable then
      healWindow.healer.items.itemList:destroyChildren()
      for _, entry in pairs(currentSettings.itemTable) do
        local label = UI.createWidget("ItemEntry", healWindow.healer.items.itemList)
        label.enabled:setChecked(entry.enabled)
        label.enabled.onClick = function(widget)
          standBySpells = false
          standByItems = false
          entry.enabled = not entry.enabled
          label.enabled:setChecked(entry.enabled)
        end
        label.remove.onClick = function(widget)
          standBySpells = false
          standByItems = false
          table.removevalue(currentSettings.itemTable, entry)
          reindexTable(currentSettings.itemTable)
          label:destroy()
        end
        local _, previewId = resolveItem(entry.item)
        label.id:setItemId(previewId or entry.item)
        label:setText(entry.origin .. entry.sign .. entry.value .. ": " .. entry.item)
      end
    end
  end
  refreshItems()

  healWindow.healer.spells.MoveUp.onClick = function(widget)
    local input = healWindow.healer.spells.spellList:getFocusedChild()
    if not input then return end
    local index = healWindow.healer.spells.spellList:getChildIndex(input)
    if index < 2 then return end

    local t = currentSettings.spellTable

    t[index],t[index-1] = t[index-1], t[index]
    healWindow.healer.spells.spellList:moveChildToIndex(input, index - 1)
    healWindow.healer.spells.spellList:ensureChildVisible(input)
  end

  healWindow.healer.spells.MoveDown.onClick = function(widget)
    local input = healWindow.healer.spells.spellList:getFocusedChild()
    if not input then return end
    local index = healWindow.healer.spells.spellList:getChildIndex(input)
    if index >= healWindow.healer.spells.spellList:getChildCount() then return end

    local t = currentSettings.spellTable

    t[index],t[index+1] = t[index+1],t[index]
    healWindow.healer.spells.spellList:moveChildToIndex(input, index + 1)
    healWindow.healer.spells.spellList:ensureChildVisible(input)
  end

  healWindow.healer.items.MoveUp.onClick = function(widget)
    local input = healWindow.healer.items.itemList:getFocusedChild()
    if not input then return end
    local index = healWindow.healer.items.itemList:getChildIndex(input)
    if index < 2 then return end

    local t = currentSettings.itemTable

    t[index],t[index-1] = t[index-1], t[index]
    healWindow.healer.items.itemList:moveChildToIndex(input, index - 1)
    healWindow.healer.items.itemList:ensureChildVisible(input)
  end

  healWindow.healer.items.MoveDown.onClick = function(widget)
    local input = healWindow.healer.items.itemList:getFocusedChild()
    if not input then return end
    local index = healWindow.healer.items.itemList:getChildIndex(input)
    if index >= healWindow.healer.items.itemList:getChildCount() then return end

    local t = currentSettings.itemTable

    t[index],t[index+1] = t[index+1],t[index]
    healWindow.healer.items.itemList:moveChildToIndex(input, index + 1)
    healWindow.healer.items.itemList:ensureChildVisible(input)
  end

  healWindow.healer.spells.addSpell.onClick = function(widget)
 
    local spellFormula = healWindow.healer.spells.spellFormula:getText():trim()
    local manaCost = tonumber(healWindow.healer.spells.manaCost:getText())
    local spellTrigger = tonumber(healWindow.healer.spells.spellValue:getText())
    local spellSource = healWindow.healer.spells.spellSource:getCurrentOption().text
    local spellEquasion = healWindow.healer.spells.spellCondition:getCurrentOption().text
    local source
    local equasion

    if not manaCost then  
      warn("HealBot: incorrect mana cost value!")       
      healWindow.healer.spells.spellFormula:setText('')
      healWindow.healer.spells.spellValue:setText('')
      healWindow.healer.spells.manaCost:setText('') 
      return 
    end
    if not spellTrigger then  
      warn("HealBot: incorrect condition value!") 
      healWindow.healer.spells.spellFormula:setText('')
      healWindow.healer.spells.spellValue:setText('')
      healWindow.healer.spells.manaCost:setText('')
      return 
    end

    if spellSource == "Current Mana" then
      source = "MP"
    elseif spellSource == "Current Health" then
      source = "HP"
    elseif spellSource == "Mana Percent" then
      source = "MP%"
    elseif spellSource == "Health Percent" then
      source = "HP%"
    else
      source = "burst"
    end
    
    if spellEquasion == "Above" then
      equasion = ">"
    elseif spellEquasion == "Below" then
      equasion = "<"
    else
      equasion = "="
    end

    if spellFormula:len() > 0 then
      table.insert(currentSettings.spellTable,  {index = #currentSettings.spellTable+1, spell = spellFormula, sign = equasion, origin = source, cost = manaCost, value = spellTrigger, enabled = true})
      healWindow.healer.spells.spellFormula:setText('')
      healWindow.healer.spells.spellValue:setText('')
      healWindow.healer.spells.manaCost:setText('')
    end
    standBySpells = false
    standByItems = false
    refreshSpells()
  end

  local isSyncing = false
  if healWindow.healer.items.itemCustomId then
    healWindow.healer.items.itemCustomId.onTextChange = function(widget, text)
      if isSyncing then return end
      local num = tonumber(text)
      isSyncing = true
      if num and num > 0 then
        local _, previewId = resolveItem(num)
        healWindow.healer.items.itemId:setItemId(previewId or num)
      else
        healWindow.healer.items.itemId:setItemId(0)
      end
      isSyncing = false
    end

    healWindow.healer.items.itemId.onItemChange = function(widget)
      if isSyncing then return end
      local id = widget:getItemId()
      if id > 0 then
        local cur = tonumber(healWindow.healer.items.itemCustomId:getText())
        if cur ~= id then
          isSyncing = true
          healWindow.healer.items.itemCustomId:setText(tostring(id))
          isSyncing = false
        end
      end
    end
  end

  healWindow.healer.items.addItem.onClick = function(widget)
    local customId = healWindow.healer.items.itemCustomId and tonumber(healWindow.healer.items.itemCustomId:getText())
    local boxId = healWindow.healer.items.itemId:getItemId()
    local id = (customId and customId > 0 and customId) or (boxId and boxId > 0 and boxId)
    local trigger = tonumber(healWindow.healer.items.itemValue:getText())
    local src = healWindow.healer.items.itemSource:getCurrentOption().text
    local eq = healWindow.healer.items.itemCondition:getCurrentOption().text
    local source
    local equasion

    if not trigger then
      warn("HealBot: incorrect trigger value!")
      healWindow.healer.items.itemValue:setText('')
      return
    end

    if not id or id <= 0 then
      warn("HealBot: incorrect item ID!")
      return
    end

    if src == "Current Mana" then
      source = "MP"
    elseif src == "Current Health" then
      source = "HP"
    elseif src == "Mana Percent" then
      source = "MP%"
    elseif src == "Health Percent" then
      source = "HP%"
    else
      source = "burst"
    end
    
    if eq == "Above" then
      equasion = ">"
    elseif eq == "Below" then
      equasion = "<"
    else
      equasion = "="
    end

    table.insert(currentSettings.itemTable, {index = #currentSettings.itemTable+1, item = id, sign = equasion, origin = source, value = trigger, enabled = true})
    standBySpells = false
    standByItems = false
    refreshItems()
    healWindow.healer.items.itemId:setItemId(0)
    if healWindow.healer.items.itemCustomId then
      healWindow.healer.items.itemCustomId:setText('')
    end
    healWindow.healer.items.itemValue:setText('')
  end

  healWindow.closeButton.onClick = function(widget)
    healWindow:hide()
  end

  local loadSettings = function()
    ui.title:setOn(currentSettings.enabled)
    setProfileName()
    healWindow.settings.profiles.Name:setText(currentSettings.name)
    refreshSpells()
    refreshItems()
    healWindow.settings.list.Visible:setChecked(currentSettings.Visible)
    healWindow.settings.list.Cooldown:setChecked(currentSettings.Cooldown)
    healWindow.settings.list.Delay:setChecked(currentSettings.Delay)
    healWindow.settings.list.MessageDelay:setChecked(currentSettings.MessageDelay)
    healWindow.settings.list.Interval:setChecked(currentSettings.Interval)
    healWindow.settings.list.Conditions:setChecked(currentSettings.Conditions)
  end
  loadSettings()

  local profileChange = function()
    setActiveProfile()
    activeProfileColor()
    loadSettings()
    vBotConfigSave("heal")
  end

  local resetSettings = function()
    currentSettings.enabled = false
    currentSettings.spellTable = {}
    currentSettings.itemTable = {}
    currentSettings.Visible = true
    currentSettings.Cooldown = true
    currentSettings.Delay = true
    currentSettings.MessageDelay = false
    currentSettings.Interval = true
    currentSettings.Conditions = true
    currentSettings.name = "Profile #" .. HealBotConfig.currentBotProfile
  end

  -- profile buttons
  for i=1,5 do
    local button = ui[i]
      button.onClick = function()
      HealBotConfig.currentHealBotProfile = i
      profileChange()
    end
  end

  healWindow.settings.profiles.ResetSettings.onClick = function()
    resetSettings()
    loadSettings()
  end


  -- public functions
  HealBot = {} -- global table

  HealBot.isOn = function()
    return currentSettings.enabled
  end

  HealBot.isOff = function()
    return not currentSettings.enabled
  end

  HealBot.setOff = function()
    currentSettings.enabled = false
    ui.title:setOn(currentSettings.enabled)
    vBotConfigSave("atk")
  end

  HealBot.setOn = function()
    currentSettings.enabled = true
    ui.title:setOn(currentSettings.enabled)
    vBotConfigSave("atk")
  end

  HealBot.getActiveProfile = function()
    return HealBotConfig.currentHealBotProfile -- returns number 1-5
  end

  HealBot.setActiveProfile = function(n)
    if not n or not tonumber(n) or n < 1 or n > 5 then
      return error("[HealBot] wrong profile parameter! should be 1 to 5 is " .. n)
    else
      HealBotConfig.currentHealBotProfile = n
      profileChange()
    end
  end

  HealBot.show = function()
    healWindow:show()
    healWindow:raise()
    healWindow:focus()
  end
end

-- spells
macro(100, function()
  if standBySpells then return end
  if not currentSettings.enabled then return end
  local somethingIsOnCooldown = false

  for _, entry in pairs(currentSettings.spellTable) do
    if entry.enabled and entry.cost < mana() then
      if canCast(entry.spell, not currentSettings.Conditions, not currentSettings.Cooldown) then
        if entry.origin == "HP%" then
          if entry.sign == "=" and hppercent() == entry.value then
            say(entry.spell)
            return
          elseif entry.sign == ">" and hppercent() >= entry.value then
            say(entry.spell)
            return
          elseif entry.sign == "<" and hppercent() <= entry.value then
            say(entry.spell)
            return
          end
        elseif entry.origin == "HP" then
          if entry.sign == "=" and hp() == entry.value then
            say(entry.spell)
            return
          elseif entry.sign == ">" and hp() >= entry.value then
            say(entry.spell)
            return
          elseif entry.sign == "<" and hp() <= entry.value then
            say(entry.spell)
            return
          end
        elseif entry.origin == "MP%" then
          if entry.sign == "=" and manapercent() == entry.value then
            say(entry.spell)
            return
          elseif entry.sign == ">" and manapercent() >= entry.value then
            say(entry.spell)
            return
          elseif entry.sign == "<" and manapercent() <= entry.value then
            say(entry.spell)
            return
          end
        elseif entry.origin == "MP" then
          if entry.sign == "=" and mana() == entry.value then
            say(entry.spell)
            return
          elseif entry.sign == ">" and mana() >= entry.value then
            say(entry.spell)
            return
          elseif entry.sign == "<" and mana() <= entry.value then
            say(entry.spell)
            return
          end    
        elseif entry.origin == "burst" then
          if entry.sign == "=" and burstDamageValue() == entry.value then
            say(entry.spell)
            return
          elseif entry.sign == ">" and burstDamageValue() >= entry.value then
            say(entry.spell)
            return
          elseif entry.sign == "<" and burstDamageValue() <= entry.value then
            say(entry.spell)
            return
          end    
        end
      else
        somethingIsOnCooldown = true
      end
    end
  end
  if not somethingIsOnCooldown then
    standBySpells = true 
  end
end)

-- items
macro(100, function()
  if not currentSettings.enabled or not currentSettings.itemTable or #currentSettings.itemTable == 0 then return end
  if standByItems then return end
  if currentSettings.Delay and vBot.isUsing then return end
  if currentSettings.MessageDelay and vBot.isUsingPotion then return end

  local targetBotLooting = TargetBot and TargetBot.isOn and TargetBot.isOn() and TargetBot.Looting and TargetBot.Looting.getStatus and TargetBot.Looting.getStatus():len() > 0
  if targetBotLooting and currentSettings.Interval then
    delay(currentSettings.MessageDelay and 200 or 700)
    return
  end

  local anyRuleTriggered = false

  for _, entry in pairs(currentSettings.itemTable) do
    if entry.enabled then
      local conditionMet = false
      
      if entry.origin == "HP%" then
        local val = hppercent()
        if entry.sign == "=" and val == entry.value then conditionMet = true
        elseif entry.sign == ">" and val >= entry.value then conditionMet = true
        elseif entry.sign == "<" and val <= entry.value then conditionMet = true end
      elseif entry.origin == "HP" then
        local val = hp()
        local targetVal = tonumber(entry.value) or entry.value
        if entry.sign == "=" and val == targetVal then conditionMet = true
        elseif entry.sign == ">" and val >= targetVal then conditionMet = true
        elseif entry.sign == "<" and val <= targetVal then conditionMet = true end
      elseif entry.origin == "MP%" then
        local val = manapercent()
        if entry.sign == "=" and val == entry.value then conditionMet = true
        elseif entry.sign == ">" and val >= entry.value then conditionMet = true
        elseif entry.sign == "<" and val <= entry.value then conditionMet = true end
      elseif entry.origin == "MP" then
        local val = mana()
        local targetVal = tonumber(entry.value) or entry.value
        if entry.sign == "=" and val == targetVal then conditionMet = true
        elseif entry.sign == ">" and val >= targetVal then conditionMet = true
        elseif entry.sign == "<" and val <= targetVal then conditionMet = true end
      elseif entry.origin == "burst" then
        local val = burstDamageValue and burstDamageValue() or 0
        if entry.sign == "=" and val == entry.value then conditionMet = true
        elseif entry.sign == ">" and val >= entry.value then conditionMet = true
        elseif entry.sign == "<" and val <= entry.value then conditionMet = true end
      end

      if conditionMet then
        local itemObj, actualId = resolveItem(entry.item)
        if not currentSettings.Visible or itemObj then
          anyRuleTriggered = true
          useHealItem(itemObj, actualId)
          if not currentSettings.MessageDelay then
            delay(400)
          end
          return
        end
      end
    end
  end

  if not anyRuleTriggered then
    standByItems = true
  end
end)
UI.Separator()

onPlayerHealthChange(function(healthPercent)
  standByItems = false
  standBySpells = false
end)

onManaChange(function(player, mana, maxMana, oldMana, oldMaxMana)
  standByItems = false
  standBySpells = false
end)