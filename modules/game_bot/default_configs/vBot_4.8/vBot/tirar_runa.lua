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
    delay = 201,         -- 201 ms default
    areaRadius = 3,
    maxRange = 6,
    autoTarget = true,   -- Auto-apuntar a donde pegue a mas monstruos
    safePvp = true,
    ignoreParty = true
  }
end

local config = storage[panelName]
-- Ensure delay is 201 if it had the old default or was unset
if config.delay == 2000 or not config.delay then
  config.delay = 201
end

-- Main UI panel in Target Tab (Placed prominently at top)
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
    ui.status:setText(string.format("%s %s (%s) [%dms]", onText, modeText, sName, config.delay or 201))
  elseif config.mode == 3 then
    ui.status:setText(string.format("%s %s (%s) [%dms]", onText, modeText, aName, config.delay or 201))
  else
    ui.status:setText(string.format("%s %s (%s/%s >=%d) [%dms]", onText, modeText, sName, aName, config.minMonsters or 2, config.delay or 201))
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

runeWindow.delay:setValue(config.delay or 201)
runeWindow.delayLabel:setText("Delay entre Runas: " .. tostring(config.delay or 201) .. " ms")

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
  updateStatus()
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

-- Check whether (mx, my) is within standard 37-tile Tibia area rune blast centered at (cx, cy)
local function isBlastHit(cx, cy, mx, my)
  local dx = math.abs(mx - cx)
  local dy = math.abs(my - cy)
  return (dx <= 3 and dy <= 3) and (dx + dy <= 4 or (dx <= 2 and dy <= 2))
end

-- Function to find the optimal target position where the area rune hits the most monsters
local function getBestAreaTarget(aliveMonsters, currentTarget)
  local playerPos = pos()
  local pz = playerPos.z

  local candidatePositions = {}
  local visited = {}

  local function addCandidate(p, creature)
    if not p then return end
    local key = p.x .. "," .. p.y
    if not visited[key] then
      visited[key] = true
      table.insert(candidatePositions, { pos = p, creature = creature })
    end
  end

  if currentTarget and currentTarget:getPosition().z == pz then
    addCandidate(currentTarget:getPosition(), currentTarget)
  end

  for i = 1, #aliveMonsters do
    local m = aliveMonsters[i]
    addCandidate(m:getPosition(), m)
  end

  -- Midpoints between pairs of monsters
  for i = 1, #aliveMonsters do
    local p1 = aliveMonsters[i]:getPosition()
    for j = i + 1, #aliveMonsters do
      local p2 = aliveMonsters[j]:getPosition()
      local dist = math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y))
      if dist <= 6 then
        local midX = math.floor((p1.x + p2.x) / 2)
        local midY = math.floor((p1.y + p2.y) / 2)
        addCandidate({ x = midX, y = midY, z = pz }, nil)
        local ceilX = math.ceil((p1.x + p2.x) / 2)
        local ceilY = math.ceil((p1.y + p2.y) / 2)
        if ceilX ~= midX or ceilY ~= midY then
          addCandidate({ x = ceilX, y = ceilY, z = pz }, nil)
        end
      end
    end
  end

  local allSpecs = getSpectators()
  local bestScore = -1
  local bestPos = nil
  local bestCreature = nil

  for _, cand in ipairs(candidatePositions) do
    local cp = cand.pos
    local distFromPlayer = getDistanceBetween(playerPos, cp)
    if distFromPlayer <= (config.maxRange or 6) then
      local tile = g_map.getTile(cp)
      if tile and tile:canShoot() then
        -- PVP Safe check: ensure no non-party player is hit by this blast
        local pvpBlocked = false
        if config.safePvp then
          for _, spec in ipairs(allSpecs) do
            if spec:isPlayer() and not spec:isLocalPlayer() and spec:getPosition().z == pz then
              local sp = spec:getPosition()
              if isBlastHit(cp.x, cp.y, sp.x, sp.y) then
                if not config.ignoreParty or spec:getShield() <= 2 then
                  pvpBlocked = true
                  break
                end
              end
            end
          end
        end

        if not pvpBlocked then
          local hits = 0
          for _, m in ipairs(aliveMonsters) do
            local mp = m:getPosition()
            if isBlastHit(cp.x, cp.y, mp.x, mp.y) then
              hits = hits + 1
            end
          end

          local isCurTarget = currentTarget and (cp.x == currentTarget:getPosition().x and cp.y == currentTarget:getPosition().y)
          local better = hits > bestScore or (hits == bestScore and isCurTarget)
          if better then
            bestScore = hits
            bestPos = cp
            bestCreature = cand.creature
          end
        end
      end
    end
  end

  return bestPos, bestCreature, bestScore
end

-- Core Rune Shooter Loop (runs every 20ms for fast, exact 201ms responsiveness)
local lastRuneCast = 0

macro(20, function()
  if not config.enabled then return end
  if isInPz() then return end

  local currentNow = now
  local delayMs = config.delay or 201
  if lastRuneCast + delayMs > currentNow then return end

  local playerPos = pos()
  local pz = playerPos.z

  -- 1. Gather all alive monsters on current floor within range
  local aliveMonsters = {}
  for _, spec in ipairs(getSpectators()) do
    if spec:isMonster() and spec:getPosition().z == pz and spec:getHealthPercent() > 0 then
      if getDistanceBetween(playerPos, spec:getPosition()) <= (config.maxRange or 6) then
        table.insert(aliveMonsters, spec)
      end
    end
  end

  if #aliveMonsters == 0 then return end

  -- 2. Find current target
  local currentTarget = g_game.getAttackingCreature()
  if currentTarget then
    if currentTarget:getPosition().z ~= pz or currentTarget:getHealthPercent() <= 0 then
      currentTarget = nil
    end
  end

  -- If no target and autoTarget enabled, pick closest monster as target
  if not currentTarget and config.autoTarget then
    local closestDist = 999
    local closestMonster = nil
    for _, m in ipairs(aliveMonsters) do
      local dist = getDistanceBetween(playerPos, m:getPosition())
      if dist < closestDist then
        closestDist = dist
        closestMonster = m
      end
    end
    if closestMonster then
      currentTarget = closestMonster
      if not g_game.isAttacking() then
        g_game.attack(closestMonster)
      end
    end
  end

  -- 3. Determine if we should shoot Area or Single rune
  local wantArea = false
  if config.mode == 3 then
    -- Always area
    wantArea = true
  elseif config.mode == 1 then
    -- Dinamico: use area if monsters count >= minMonsters
    wantArea = #aliveMonsters >= (config.minMonsters or 2)
  else
    -- Solo 1 monster (Single)
    wantArea = false
  end

  -- 4. Execute shooting
  if wantArea and config.areaRuneId and config.areaRuneId > 0 then
    -- AREA RUNE: Aim where it hits the MAXIMUM number of monsters
    local bestPos, bestCreature, bestScore = nil, nil, 0
    if config.autoTarget then
      bestPos, bestCreature, bestScore = getBestAreaTarget(aliveMonsters, currentTarget)
    elseif currentTarget then
      bestPos = currentTarget:getPosition()
      bestCreature = currentTarget
      bestScore = 1
    end

    if bestPos then
      -- If we found an optimal spot for area rune
      local targetThing = bestCreature
      if not targetThing then
        local tile = g_map.getTile(bestPos)
        if tile then
          targetThing = tile:getTopUseThing() or tile:getGround() or tile
        end
      end
      if targetThing then
        useWith(config.areaRuneId, targetThing)
        lastRuneCast = currentNow
        return
      end
    end

    -- If area was blocked by PVP Safe, fallback to Single rune if available
    if config.singleRuneId and config.singleRuneId > 0 and currentTarget then
      useWith(config.singleRuneId, currentTarget)
      lastRuneCast = currentNow
      return
    end
  else
    -- SINGLE RUNE: Aim directly at target creature
    local targetToShoot = currentTarget or aliveMonsters[1]
    if targetToShoot and config.singleRuneId and config.singleRuneId > 0 then
      useWith(config.singleRuneId, targetToShoot)
      lastRuneCast = currentNow
      return
    end
  end
end)
