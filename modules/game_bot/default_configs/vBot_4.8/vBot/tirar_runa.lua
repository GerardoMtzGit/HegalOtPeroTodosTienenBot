local targetingTab = storage.extras and storage.extras.joinBot and "Cave" or "Target"
setDefaultTab(targetingTab)

local panelName = "tirar_runa"

if not storage[panelName] then
  storage[panelName] = {
    enabled = false,
    mode = 1, -- 1: Dinamico, 2: Solo 1, 3: Varios (Area)
    singleRuneId = 3155, -- SD default
    areaRuneId = 3191,   -- GFB default
    minMonsters = 2,
    delay = 2000,
    areaRadius = 3,
    maxRange = 6,
    autoTarget = true,
    safePvp = true,
    ignoreParty = true
  }
end

local config = storage[panelName]

-- Main UI panel in Target Tab (Placed prominently)
local ui = setupUI([[
Panel
  height: 48
  margin-top: 5
  margin-left: 2
  margin-right: 2

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: configBtn.left
    margin-right: 4
    height: 20
    text-align: center
    !text: tr('Tirar Runa')

  Button
    id: configBtn
    anchors.top: parent.top
    anchors.right: parent.right
    width: 48
    height: 20
    text: Setup
    font: cipsoftFont

  Label
    id: status
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 3
    font: cipsoftFont
    text-align: center
    color: #a0a0a0
    text: [OFF] Dinamico | SD / GFB (>=2)

  HorizontalSeparator
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
]])

local runeNames = {
  [3155] = "SD",
  [3198] = "HMM",
  [3158] = "Icicle",
  [3189] = "Fireball",
  [3179] = "Stalagmite",
  [3182] = "Holy",
  [3200] = "Explo",
  [3191] = "GFB",
  [3161] = "Ava",
  [3202] = "Thunder",
  [3175] = "Stone",
  [3192] = "FBomb",
  [3173] = "PBomb",
  [3149] = "EBomb"
}

local function getRuneShortName(id)
  return runeNames[id] or ("ID:" .. tostring(id))
end

local function updateStatus()
  local modeText = "Dinamico"
  if config.mode == 2 then
    modeText = "Solo 1"
  elseif config.mode == 3 then
    modeText = "Area"
  end
  local onText = config.enabled and "[ON]" or "[OFF]"
  local sName = getRuneShortName(config.singleRuneId)
  local aName = getRuneShortName(config.areaRuneId)
  if config.mode == 2 then
    ui.status:setText(string.format("%s %s (%s)", onText, modeText, sName))
  elseif config.mode == 3 then
    ui.status:setText(string.format("%s %s (%s)", onText, modeText, aName))
  else
    ui.status:setText(string.format("%s %s (%s / %s >=%d)", onText, modeText, sName, aName, config.minMonsters or 2))
  end
  if config.enabled then
    ui.status:setColor("#00ff00")
  else
    ui.status:setColor("#a0a0a0")
  end
end

-- Create configuration window
local runeWindow = UI.createWindow('TirarRunaWindow')
runeWindow:hide()

-- Populate Mode ComboBox
local modes = {
  { text = "Dinamico (1=Single, 2+=Area)", id = 1 },
  { text = "Solo 1 Monster (Single)", id = 2 },
  { text = "Varios Monsters (Area)", id = 3 }
}
for _, m in ipairs(modes) do
  runeWindow.modeCombo:addOption(m.text, m.id)
end

-- Preset single runes
local singleRunes = {
  { text = "Sudden Death (SD)", id = 3155 },
  { text = "Heavy Magic Missile (HMM)", id = 3198 },
  { text = "Icicle", id = 3158 },
  { text = "Fireball", id = 3189 },
  { text = "Stalagmite", id = 3179 },
  { text = "Holy Missile", id = 3182 },
  { text = "Explosion", id = 3200 },
  { text = "Personalizada", id = 0 }
}
for _, r in ipairs(singleRunes) do
  runeWindow.singlePanel.singleCombo:addOption(r.text, r.id)
end

-- Preset area runes
local areaRunes = {
  { text = "Great Fireball (GFB)", id = 3191 },
  { text = "Avalanche", id = 3161 },
  { text = "Thunderstorm", id = 3202 },
  { text = "Stone Shower", id = 3175 },
  { text = "Fire Bomb", id = 3192 },
  { text = "Poison Bomb", id = 3173 },
  { text = "Energy Bomb", id = 3149 },
  { text = "Personalizada", id = 0 }
}
for _, r in ipairs(areaRunes) do
  runeWindow.areaPanel.areaCombo:addOption(r.text, r.id)
end

local function setSingleRuneOption(runeId)
  local found = false
  for _, r in ipairs(singleRunes) do
    if r.id == runeId and r.id ~= 0 then
      runeWindow.singlePanel.singleCombo:setOption(r.text)
      found = true
      break
    end
  end
  if not found then
    runeWindow.singlePanel.singleCombo:setOption("Personalizada")
  end
  runeWindow.singlePanel.singleItem:setItemId(runeId)
  runeWindow.singlePanel.singleId:setText(tostring(runeId))
end

local function setAreaRuneOption(runeId)
  local found = false
  for _, r in ipairs(areaRunes) do
    if r.id == runeId and r.id ~= 0 then
      runeWindow.areaPanel.areaCombo:setOption(r.text)
      found = true
      break
    end
  end
  if not found then
    runeWindow.areaPanel.areaCombo:setOption("Personalizada")
  end
  runeWindow.areaPanel.areaItem:setItemId(runeId)
  runeWindow.areaPanel.areaId:setText(tostring(runeId))
end

-- Init values in window
for _, m in ipairs(modes) do
  if m.id == config.mode then
    runeWindow.modeCombo:setOption(m.text)
    break
  end
end
setSingleRuneOption(config.singleRuneId)
setAreaRuneOption(config.areaRuneId)

runeWindow.minMonsters:setValue(config.minMonsters or 2)
runeWindow.minMonstersLabel:setText("Min. Monsters para Area: " .. tostring(config.minMonsters or 2))

runeWindow.delay:setValue(config.delay or 2000)
runeWindow.delayLabel:setText("Delay entre Runas: " .. tostring(config.delay or 2000) .. " ms")

runeWindow.autoTarget:setChecked(config.autoTarget)
runeWindow.safePvp:setChecked(config.safePvp)

-- Event listeners
runeWindow.modeCombo.onOptionChange = function(widget, option, data)
  for _, m in ipairs(modes) do
    if m.text == option then
      config.mode = m.id
      break
    end
  end
  updateStatus()
end

runeWindow.singlePanel.singleCombo.onOptionChange = function(widget, option, data)
  for _, r in ipairs(singleRunes) do
    if r.text == option then
      if r.id > 0 then
        config.singleRuneId = r.id
        runeWindow.singlePanel.singleItem:setItemId(r.id)
        runeWindow.singlePanel.singleId:setText(tostring(r.id))
      end
      break
    end
  end
  updateStatus()
end

runeWindow.singlePanel.singleItem.onItemChange = function(widget)
  local itemId = widget:getItemId()
  if itemId and itemId > 0 and itemId ~= config.singleRuneId then
    config.singleRuneId = itemId
    setSingleRuneOption(itemId)
    updateStatus()
  end
end

runeWindow.singlePanel.singleId.onTextChange = function(widget, text)
  local val = tonumber(text)
  if val and val > 0 and val ~= config.singleRuneId then
    config.singleRuneId = val
    runeWindow.singlePanel.singleItem:setItemId(val)
    local found = false
    for _, r in ipairs(singleRunes) do
      if r.id == val and r.id ~= 0 then
        runeWindow.singlePanel.singleCombo:setOption(r.text)
        found = true
        break
      end
    end
    if not found then
      runeWindow.singlePanel.singleCombo:setOption("Personalizada")
    end
    updateStatus()
  end
end

runeWindow.areaPanel.areaCombo.onOptionChange = function(widget, option, data)
  for _, r in ipairs(areaRunes) do
    if r.text == option then
      if r.id > 0 then
        config.areaRuneId = r.id
        runeWindow.areaPanel.areaItem:setItemId(r.id)
        runeWindow.areaPanel.areaId:setText(tostring(r.id))
      end
      break
    end
  end
  updateStatus()
end

runeWindow.areaPanel.areaItem.onItemChange = function(widget)
  local itemId = widget:getItemId()
  if itemId and itemId > 0 and itemId ~= config.areaRuneId then
    config.areaRuneId = itemId
    setAreaRuneOption(itemId)
    updateStatus()
  end
end

runeWindow.areaPanel.areaId.onTextChange = function(widget, text)
  local val = tonumber(text)
  if val and val > 0 and val ~= config.areaRuneId then
    config.areaRuneId = val
    runeWindow.areaPanel.areaItem:setItemId(val)
    local found = false
    for _, r in ipairs(areaRunes) do
      if r.id == val and r.id ~= 0 then
        runeWindow.areaPanel.areaCombo:setOption(r.text)
        found = true
        break
      end
    end
    if not found then
      runeWindow.areaPanel.areaCombo:setOption("Personalizada")
    end
    updateStatus()
  end
end

runeWindow.minMonsters.onValueChange = function(widget, value)
  config.minMonsters = value
  runeWindow.minMonstersLabel:setText("Min. Monsters para Area: " .. tostring(value))
  updateStatus()
end

runeWindow.delay.onValueChange = function(widget, value)
  config.delay = value
  runeWindow.delayLabel:setText("Delay entre Runas: " .. tostring(value) .. " ms")
end

runeWindow.autoTarget.onClick = function(widget)
  config.autoTarget = not config.autoTarget
  widget:setChecked(config.autoTarget)
end

runeWindow.safePvp.onClick = function(widget)
  config.safePvp = not config.safePvp
  widget:setChecked(config.safePvp)
end

runeWindow.closeButton.onClick = function()
  runeWindow:hide()
end

-- Main switch wiring
ui.title:setOn(config.enabled)
ui.title.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
  updateStatus()
end

ui.configBtn.onClick = function()
  runeWindow:show()
  runeWindow:raise()
  runeWindow:focus()
end

updateStatus()

-- Core Rune Shooter Loop
local lastRuneCast = 0

macro(100, function()
  if not config.enabled then return end
  if isInPz() then return end

  local currentNow = now
  if lastRuneCast + config.delay > currentNow then return end

  -- 1. Find target
  local targetCreature = g_game.getAttackingCreature()
  if targetCreature then
    if targetCreature:getPosition().z ~= posz() or targetCreature:getHealthPercent() <= 0 then
      targetCreature = nil
    end
  end

  -- If no target and autoTarget enabled, search for closest monster
  if not targetCreature and config.autoTarget then
    local playerPos = pos()
    local closestDist = 999
    local closestMonster = nil
    for _, spec in ipairs(getSpectators()) do
      if spec:isMonster() and spec:getPosition().z == posz() and spec:getHealthPercent() > 0 then
        local dist = getDistanceBetween(playerPos, spec:getPosition())
        if dist <= config.maxRange and dist < closestDist then
          closestDist = dist
          closestMonster = spec
        end
      end
    end
    if closestMonster then
      targetCreature = closestMonster
      if not g_game.isAttacking() then
        g_game.attack(closestMonster)
      end
    end
  end

  if not targetCreature then return end

  -- 2. Count monsters in area around target
  local tPos = targetCreature:getPosition()
  local monstersAround = 0
  local playerNear = false
  for _, spec in ipairs(getSpectators()) do
    if spec:getPosition().z == tPos.z and spec:getHealthPercent() > 0 then
      local dist = math.max(math.abs(spec:getPosition().x - tPos.x), math.abs(spec:getPosition().y - tPos.y))
      if dist <= (config.areaRadius or 3) then
        if spec:isMonster() then
          monstersAround = monstersAround + 1
        elseif spec:isPlayer() and not spec:isLocalPlayer() then
          if not config.ignoreParty or spec:getShield() <= 2 then
            playerNear = true
          end
        end
      end
    end
  end

  -- 3. Determine rune to cast based on user's chosen mode
  local runeToCast = nil
  if config.mode == 2 then
    -- Solo 1 monster
    runeToCast = config.singleRuneId
  elseif config.mode == 3 then
    -- Varios monsters (Area)
    if config.safePvp and playerNear then
      runeToCast = config.singleRuneId
    else
      runeToCast = config.areaRuneId
    end
  else
    -- Dinamico (1 = single, >= minMonsters = area)
    if monstersAround >= (config.minMonsters or 2) and not (config.safePvp and playerNear) then
      runeToCast = config.areaRuneId
    else
      runeToCast = config.singleRuneId
    end
  end

  if not runeToCast or runeToCast <= 0 then return end

  -- 4. Cast rune
  useWith(runeToCast, targetCreature)
  lastRuneCast = currentNow
end)
