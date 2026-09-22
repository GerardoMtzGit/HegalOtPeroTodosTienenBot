-- Tab Iconos - Configuracion central de iconos HUD y Quick-Heal
setDefaultTab("Iconos")

local panelName = "iconsTab"
if not storage[panelName] then
  storage[panelName] = {
    enabled = true,
    targetPercent = 90,
    itemId = 438,
    delay = 300,
    autoMaintain = false,
    lockPosition = true,
    pos = { x = 20, y = 30 }
  }
end
local config = storage[panelName]
if not config.pos then
  config.pos = { x = 20, y = 30 }
end

local PotionAliases = {
  [438] = {23373, 23374, 438}, -- Ultimate Mana (23373) / Ultimate Spirit (23374)
  [23373] = {23373, 438},
  [23374] = {23374, 438},
  [144] = {238, 144},          -- Great Mana
  [238] = {238, 144},
  [93]  = {237, 93},           -- Strong Mana
  [237] = {237, 93},
  [56]  = {268, 56},           -- Mana Potion
  [268] = {268, 56},
  [379] = {7643, 379},         -- Ultimate Health
  [7643] = {7643, 379},
  [625] = {23375, 625},        -- Supreme Health
  [23375] = {23375, 625},
  [225] = {239, 225},          -- Great Health
  [239] = {239, 225},
  [115] = {236, 115},          -- Strong Health
  [236] = {236, 115},
  [50]  = {266, 50},           -- Health Potion
  [266] = {266, 50},
  [228] = {7642, 228},         -- Great Spirit
  [7642] = {7642, 228},
}

local function resolveItem(itemId)
  if not itemId or itemId <= 0 then return nil, itemId end

  -- 1. Look in open containers
  local it = findItem(itemId)
  if it then return it, itemId end

  -- 2. Look in inventory slots (1-10)
  if getInventoryItem then
    for slot = 1, 10 do
      local invItem = getInventoryItem(slot)
      if invItem and invItem:getId() == itemId then
        return invItem, itemId
      end
    end
  end

  -- 3. Check aliases
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

local function drinkOnce()
  local id = tonumber(config.itemId) or 438
  local itemObj, actualId = resolveItem(id)
  local ok = false

  if itemObj then
    ok = pcall(function() useWith(itemObj, player) end)
  end

  if not ok and actualId and actualId > 0 then
    ok = pcall(function() useWith(actualId, player) end)
  end

  if not ok then
    local candidates = PotionAliases[id]
    if candidates then
      for _, altId in ipairs(candidates) do
        if altId ~= actualId then
          ok = pcall(function() useWith(altId, player) end)
          if ok then break end
        end
      end
    end
  end

  return ok
end

local isDrinking = false
local manaIconWidget = nil
local statusLabel = nil
local lastTriggerTime = 0

local function updateVisuals()
  local target = tonumber(config.targetPercent) or 90
  local curMp = manapercent()

  if manaIconWidget then
    manaIconWidget:setVisible(config.enabled)
    local _, previewId = resolveItem(tonumber(config.itemId) or 438)
    manaIconWidget.item:setItemId(previewId or 23373)

    if isDrinking then
      manaIconWidget:setBorderColor("#00ffff")
      manaIconWidget:setBackgroundColor("#1e3a8aee")
      manaIconWidget.status:setBackgroundColor("#00ffff")
      manaIconWidget.text:setColor("#00ffff")
      manaIconWidget.text:setText(curMp .. "%")
    else
      manaIconWidget:setBorderColor("#3b82f6")
      manaIconWidget:setBackgroundColor("#0b1526ee")
      manaIconWidget.status:setBackgroundColor("#3b82f6")
      manaIconWidget.text:setColor("#93c5fd")
      manaIconWidget.text:setText(target .. "%")
    end

    manaIconWidget:setTooltip("Icono de Mana (ID " .. (config.itemId or 438) .. ")\n" ..
                              "Clic: Curar mana al " .. target .. "%\n" ..
                              "Estado: " .. (isDrinking and "CURANDO AL " .. target .. "%..." or "Listo") .. "\n" ..
                              "Ctrl + Arrastrar para mover")
  end

  if statusLabel then
    if isDrinking then
      statusLabel:setText("Curando Mana: " .. curMp .. "% -> " .. target .. "%...")
      statusLabel:setColor("#00ffff")
    else
      statusLabel:setText("Mana Actual: " .. curMp .. "% | Estado: Listo")
      statusLabel:setColor("#60a5fa")
    end
  end
end

local function triggerManaHeal()
  local nowMs = g_clock and g_clock.millis() or (os.time() * 1000)
  if nowMs - lastTriggerTime < 200 then return end
  lastTriggerTime = nowMs

  local target = tonumber(config.targetPercent) or 90
  local curMp = manapercent()

  if isDrinking then
    isDrinking = false
    updateVisuals()
    return
  end

  if curMp >= target then
    if manaIconWidget and manaIconWidget.text then
      manaIconWidget.text:setText("FULL")
      schedule(800, function()
        if not isDrinking and manaIconWidget and manaIconWidget.text then
          manaIconWidget.text:setText(target .. "%")
        end
      end)
    end
    return
  end

  isDrinking = true
  updateVisuals()
  -- Instant first drink
  drinkOnce()
end

local function createOrUpdateIcon()
  if manaIconWidget then return end
  local gameMapPanel = modules.game_interface and modules.game_interface.getMapPanel()
  if not gameMapPanel then return end

  manaIconWidget = g_ui.createWidget("ManaIconWidget", gameMapPanel)
  manaIconWidget.botWidget = true

  manaIconWidget:setMarginLeft(config.pos and config.pos.x or 20)
  manaIconWidget:setMarginTop(config.pos and config.pos.y or 30)

  -- Native Button click
  manaIconWidget.onClick = function(self)
    triggerManaHeal()
  end

  -- Mouse release fallback for instant response
  manaIconWidget.onMouseRelease = function(self, mousePos, mouseButton)
    if self.isBeingDragged then
      self.isBeingDragged = false
      return true
    end
    triggerManaHeal()
    return true
  end

  manaIconWidget.onDragEnter = function(self, mousePos)
    if config.lockPosition and not g_keyboard.isCtrlPressed() then
      return false
    end
    self.movingReference = { x = mousePos.x - self:getX(), y = mousePos.y - self:getY() }
    self.isBeingDragged = true
    return true
  end

  manaIconWidget.onDragLeave = function(self)
    self.isBeingDragged = false
    return true
  end

  manaIconWidget.onDragMove = function(self, mousePos, moved)
    local parent = self:getParent()
    if not parent then return false end
    local parentRect = parent:getRect()
    local newX = math.min(math.max(parentRect.x + 5, mousePos.x - self.movingReference.x), parentRect.x + parentRect.width - self:getWidth() - 5)
    local newY = math.min(math.max(parentRect.y + 5, mousePos.y - self.movingReference.y), parentRect.y + parentRect.height - self:getHeight() - 5)

    local relX = newX - parentRect.x
    local relY = newY - parentRect.y

    self:setMarginLeft(relX)
    self:setMarginTop(relY)
    config.pos = { x = relX, y = relY }
    return true
  end

  updateVisuals()
end

createOrUpdateIcon()
onGameStart(function()
  createOrUpdateIcon()
end)

-- UI inside the "Iconos" tab
local tabUi = setupUI([[
Panel
  height: 290

  BotSwitch
    id: enabledSwitch
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text: Icono de Mana en Pantalla
    height: 20

  Label
    id: statusLabel
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    text-align: center
    text: Mana Actual: 100% | Estado: Listo
    font: verdana-11px-rounded
    color: #60a5fa

  HorizontalSeparator
    id: sep1
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6

  Panel
    id: rowTarget
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    height: 22

    Label
      text: Subir mana al:
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      font: verdana-11px-rounded

    Label
      text: %
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 2
      font: verdana-11px-rounded

    TextEdit
      id: targetPercent
      anchors.right: prev.left
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 4
      width: 46
      font: verdana-11px-rounded
      text-align: center

  Panel
    id: rowItem
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    height: 30

    Label
      text: Pocion a usar:
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      font: verdana-11px-rounded

    BotItem
      id: itemBox
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      size: 26 26

    Label
      text: ID:
      anchors.right: prev.left
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 4
      font: verdana-11px-rounded

    TextEdit
      id: itemId
      anchors.right: prev.left
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 4
      width: 50
      font: verdana-11px-rounded
      text-align: center

  Panel
    id: rowDelay
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    height: 22

    Label
      text: Retardo (ms):
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      font: verdana-11px-rounded

    Label
      text: ms
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 2
      font: verdana-11px-rounded

    TextEdit
      id: delay
      anchors.right: prev.left
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 4
      width: 46
      font: verdana-11px-rounded
      text-align: center

  HorizontalSeparator
    id: sep2
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6

  BotSwitch
    id: autoMaintainSwitch
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    text: Modo Auto (Mantener siempre)
    height: 18

  BotSwitch
    id: lockPositionSwitch
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4
    text: Bloquear pos (Ctrl+Arrastrar)
    height: 18

  HorizontalSeparator
    id: sep3
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6

  Button
    id: resetPosBtn
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    height: 19
    text: Reiniciar Posicion (Top-Left)
    font: cipsoftFont

  Button
    id: testBtn
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4
    height: 19
    text: Curar Mana Ahora (Probar)
    font: cipsoftFont
]])

statusLabel = tabUi.statusLabel

tabUi.enabledSwitch:setOn(config.enabled)
tabUi.enabledSwitch.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
  updateVisuals()
end

tabUi.autoMaintainSwitch:setOn(config.autoMaintain)
tabUi.autoMaintainSwitch.onClick = function(widget)
  config.autoMaintain = not config.autoMaintain
  widget:setOn(config.autoMaintain)
end

tabUi.lockPositionSwitch:setOn(config.lockPosition)
tabUi.lockPositionSwitch.onClick = function(widget)
  config.lockPosition = not config.lockPosition
  widget:setOn(config.lockPosition)
end

tabUi.rowTarget.targetPercent:setText(tostring(config.targetPercent or 90))
tabUi.rowTarget.targetPercent.onTextChange = function(widget, text)
  local num = tonumber(text)
  if num and num > 0 and num <= 100 then
    config.targetPercent = num
    updateVisuals()
  end
end

tabUi.rowDelay.delay:setText(tostring(config.delay or 300))
tabUi.rowDelay.delay.onTextChange = function(widget, text)
  local num = tonumber(text)
  if num and num >= 50 then
    config.delay = num
  end
end

local isSyncing = false

local function updateItemPreview(id)
  local num = tonumber(id)
  if num and num > 0 then
    local _, previewId = resolveItem(num)
    tabUi.rowItem.itemBox:setItemId(previewId or num)
  else
    tabUi.rowItem.itemBox:setItemId(0)
  end
end

tabUi.rowItem.itemId:setText(tostring(config.itemId or 438))
updateItemPreview(config.itemId or 438)

tabUi.rowItem.itemId.onTextChange = function(widget, text)
  if isSyncing then return end
  local num = tonumber(text)
  isSyncing = true
  if num and num > 0 then
    config.itemId = num
    updateItemPreview(num)
    updateVisuals()
  else
    tabUi.rowItem.itemBox:setItemId(0)
  end
  isSyncing = false
end

tabUi.rowItem.itemBox.onItemChange = function(widget)
  if isSyncing then return end
  local id = widget:getItemId()
  if id > 0 then
    isSyncing = true
    config.itemId = id
    tabUi.rowItem.itemId:setText(tostring(id))
    updateVisuals()
    isSyncing = false
  end
end

tabUi.resetPosBtn.onClick = function()
  config.pos = { x = 20, y = 30 }
  if manaIconWidget then
    manaIconWidget:setMarginLeft(20)
    manaIconWidget:setMarginTop(30)
  end
end

tabUi.testBtn.onClick = function()
  triggerManaHeal()
end

UI.Separator()
UI.Label("Parametros y configuracion de iconos HUD.")
UI.Separator()

-- Rapid dedicated healing loop
macro(50, function()
  if not isDrinking and not config.autoMaintain then return end

  local target = tonumber(config.targetPercent) or 90
  local curMp = manapercent()

  if isDrinking then
    if curMp >= target then
      isDrinking = false
      updateVisuals()
      return
    end

    drinkOnce()
    updateVisuals()
    delay(tonumber(config.delay) or 300)
    return
  end

  if config.autoMaintain and curMp < target then
    drinkOnce()
    delay(tonumber(config.delay) or 300)
  end
end)

onManaChange(function(player, mana, maxMana, oldMana, oldMaxMana)
  if isDrinking or manaIconWidget then
    updateVisuals()
  end
end)

onStop(function()
  if manaIconWidget then
    manaIconWidget:destroy()
    manaIconWidget = nil
  end
end)
