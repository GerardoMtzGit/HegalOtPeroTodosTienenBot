-- Cooldown HUD 2x3 - Visualizador de Cooldowns Flotante sobre el Personaje
-- Muestra hasta 6 spells y runas en cooldown con 20% de visibilidad (minimalista)
-- Desaparecen automaticamente en cuanto estan disponibles nuevamente

setDefaultTab("Iconos")

local panelName = "cooldownHud"
if not storage[panelName] then
  storage[panelName] = {
    enabled = true,
    opacity = 20, -- 20% de visibilidad por defecto
    lockPosition = true,
    showTimer = true,
    pos = { x = 0, y = -75 }
  }
end

local config = storage[panelName]
if config.opacity == nil then config.opacity = 20 end
if config.lockPosition == nil then config.lockPosition = true end
if config.showTimer == nil then config.showTimer = true end
if not config.pos then config.pos = { x = 0, y = -75 } end

-- Tabla de runas conocidas con sus item IDs
local RuneItems = {
  [3155] = { name = "SD", duration = 2000 },
  [2268] = { name = "SD", duration = 2000 },
  [3161] = { name = "Avalanche", duration = 2000 },
  [2274] = { name = "Avalanche", duration = 2000 },
  [3191] = { name = "GFB", duration = 2000 },
  [2304] = { name = "GFB", duration = 2000 },
  [3180] = { name = "Magic Wall", duration = 2000 },
  [2293] = { name = "Magic Wall", duration = 2000 },
  [3156] = { name = "Wild Growth", duration = 2000 },
  [2269] = { name = "Wild Growth", duration = 2000 },
  [3165] = { name = "Paralyze", duration = 2000 },
  [2278] = { name = "Paralyze", duration = 2000 },
  [3175] = { name = "Stone Shower", duration = 2000 },
  [2288] = { name = "Stone Shower", duration = 2000 },
  [3202] = { name = "Thunderstorm", duration = 2000 },
  [2315] = { name = "Thunderstorm", duration = 2000 },
  [3158] = { name = "Icicle", duration = 2000 },
  [2271] = { name = "Icicle", duration = 2000 },
  [3182] = { name = "Holy Missile", duration = 2000 },
  [2295] = { name = "Holy Missile", duration = 2000 },
  [3200] = { name = "Explosion", duration = 2000 },
  [2313] = { name = "Explosion", duration = 2000 },
  [3198] = { name = "HMM", duration = 2000 },
  [2311] = { name = "HMM", duration = 2000 },
  [3160] = { name = "UH", duration = 1000 },
  [2273] = { name = "UH", duration = 1000 },
  [3192] = { name = "Fire Bomb", duration = 2000 },
  [2305] = { name = "Fire Bomb", duration = 2000 },
  [3173] = { name = "Poison Bomb", duration = 2000 },
  [2286] = { name = "Poison Bomb", duration = 2000 },
  [3149] = { name = "Energy Bomb", duration = 2000 },
  [2262] = { name = "Energy Bomb", duration = 2000 },
  [3197] = { name = "Disintegrate", duration = 2000 },
  [2310] = { name = "Disintegrate", duration = 2000 },
  [3148] = { name = "Destroy Field", duration = 2000 },
  [2261] = { name = "Destroy Field", duration = 2000 }
}

-- Mapeo directo de palabras de runas a su Item ID
local RuneWords = {
  ["adori gran mort"] = 3155, -- SD
  ["adori mas frigo"] = 3161, -- Avalanche
  ["adori mas flam"] = 3191,  -- GFB
  ["adevo grav vita"] = 3180, -- Magic Wall
  ["adevo grav tera"] = 3156, -- Wild Growth
  ["adana ani"] = 3165,       -- Paralyze
  ["adori tera"] = 3175,      -- Stone Shower
  ["adori vis"] = 3202,       -- Thunderstorm
  ["adori frigo"] = 3158,     -- Icicle
  ["adori san"] = 3182,       -- Holy Missile
  ["adevo res flam"] = 3192,  -- Fire Bomb
  ["adevo res tera"] = 3173,  -- Poison Bomb
  ["adevo res vis"] = 3149,   -- Energy Bomb
  ["adana mort"] = 3197,      -- Disintegrate
  ["adana grav"] = 3148,      -- Destroy Field
  ["adura vita"] = 3160       -- UH
}

-- Mapeo rapido de Spells comunes con sus IDs oficiales para sprite sheet
local SpellCatalog = {
  ["utani hur"] = { id = 6, dur = 2000, name = "Haste" },
  ["utani gran hur"] = { id = 41, dur = 2000, name = "Strong Haste" },
  ["utamo vita"] = { id = 44, dur = 2000, name = "Magic Shield" },
  ["exevo tera hur"] = { id = 117, dur = 4000, name = "Terra Wave" },
  ["exevo frigo hur"] = { id = 116, dur = 4000, name = "Ice Wave" },
  ["exevo flam hur"] = { id = 14, dur = 4000, name = "Fire Wave" },
  ["exevo vis hur"] = { id = 13, dur = 4000, name = "Energy Wave" },
  ["exevo gran mas flam"] = { id = 24, dur = 40000, name = "Hell's Core" },
  ["exevo gran mas vis"] = { id = 25, dur = 40000, name = "Rage of the Skies" },
  ["exevo gran mas tera"] = { id = 119, dur = 40000, name = "Wrath of Nature" },
  ["exevo gran mas frigo"] = { id = 118, dur = 40000, name = "Eternal Winter" },
  ["exori frigo"] = { id = 111, dur = 2000, name = "Ice Strike" },
  ["exori flam"] = { id = 88, dur = 2000, name = "Flame Strike" },
  ["exori vis"] = { id = 89, dur = 2000, name = "Energy Strike" },
  ["exori tera"] = { id = 112, dur = 2000, name = "Terra Strike" },
  ["exori mort"] = { id = 87, dur = 2000, name = "Death Strike" },
  ["exori san"] = { id = 114, dur = 2000, name = "Divine Caldera" },
  ["exori gran con"] = { id = 115, dur = 4000, name = "Strong Ethereal Spear" },
  ["exori con"] = { id = 113, dur = 2000, name = "Ethereal Spear" },
  ["exori gran"] = { id = 105, dur = 6000, name = "Fierce Berserk" },
  ["exori"] = { id = 80, dur = 4000, name = "Berserk" },
  ["exori min"] = { id = 106, dur = 6000, name = "Front Sweep" },
  ["exori mas"] = { id = 107, dur = 8000, name = "Groundshaker" },
  ["exeta res"] = { id = 91, dur = 2000, name = "Challenge" },
  ["utito tempo"] = { id = 135, dur = 2000, name = "Blood Rage" },
  ["utamo tempo"] = { id = 136, dur = 2000, name = "Protector" },
  ["exana kor"] = { id = 140, dur = 1000, name = "Cure Bleeding" },
  ["exura"] = { id = 1, dur = 1000, name = "Light Healing" },
  ["exura gran"] = { id = 2, dur = 1000, name = "Intense Healing" },
  ["exura vita"] = { id = 3, dur = 1000, name = "Ultimate Healing" },
  ["exura sio"] = { id = 84, dur = 1000, name = "Heal Friend" },
  ["exura gran mas res"] = { id = 82, dur = 2000, name = "Mass Healing" },
  ["exana mort"] = { id = 81, dur = 1000, name = "Cure Curse" },
  ["exana pox"] = { id = 29, dur = 1000, name = "Cure Poison" }
}

-- Funcion para calcular el clip en la hoja de sprites de 32x32 (12 columnas por fila)
local function getSpellClip(iconId)
  local id = tonumber(iconId) or 1
  if modules.gamelib and modules.gamelib.Spells and modules.gamelib.Spells.getImageClip then
    local clip = nil
    pcall(function() clip = modules.gamelib.Spells.getImageClip(id, 'Default') end)
    if clip and type(clip) == "string" and clip:len() > 0 then
      return clip
    end
  end

  local col = (id - 1) % 12
  local row = math.floor((id - 1) / 12)
  return string.format("%d %d 32 32", col * 32, row * 32)
end

-- Lista de cooldowns activos (maximo 6)
local activeCooldowns = {}
local hudWidget = nil
local slots = {}

local function addOrUpdateCooldown(entry)
  if not config.enabled then return end
  local nowMs = now or (os.time() * 1000)
  entry.startTime = nowMs
  entry.endTime = nowMs + (entry.duration or 2000)

  -- Buscar si ya esta en la lista
  local foundIndex = nil
  for i, c in ipairs(activeCooldowns) do
    if c.key == entry.key then
      foundIndex = i
      break
    end
  end

  if foundIndex then
    activeCooldowns[foundIndex] = entry
  else
    table.insert(activeCooldowns, 1, entry)
    if #activeCooldowns > 6 then
      table.remove(activeCooldowns)
    end
  end
end

local lastSpokenSpell = nil
local lastSpokenTime = 0

-- Deteccion de Spells por chat
onTalk(function(name, level, mode, text, channelId, pos)
  if not config.enabled then return end
  if name ~= player:getName() then return end
  local phrase = text:lower():trim()

  -- 1. Verificar si son palabras de runa
  local runeId = RuneWords[phrase]
  if runeId then
    addOrUpdateCooldown({
      key = "rune_" .. runeId,
      type = "rune",
      runeId = runeId,
      name = "Rune " .. runeId,
      duration = 2000
    })
    return
  end

  -- 2. Verificar en el catalogo de Spells
  local info = SpellCatalog[phrase]
  if info then
    lastSpokenSpell = phrase
    lastSpokenTime = now or (os.time() * 1000)
    addOrUpdateCooldown({
      key = "spell_" .. phrase,
      type = "spell",
      spellWords = phrase,
      iconId = info.id,
      name = info.name,
      duration = info.dur or 2000
    })
    return
  end

  -- 3. Consulta generica en SpellInfo de gamelib
  if modules.gamelib and modules.gamelib.SpellInfo and modules.gamelib.SpellInfo['Default'] then
    for k, v in pairs(modules.gamelib.SpellInfo['Default']) do
      if v.words and v.words:lower() == phrase then
        lastSpokenSpell = phrase
        lastSpokenTime = now or (os.time() * 1000)
        local dur = v.exhaustion or 2000
        addOrUpdateCooldown({
          key = "spell_" .. phrase,
          type = "spell",
          spellWords = phrase,
          iconId = v.id or 1,
          name = k,
          duration = dur
        })
        return
      end
    end
  end
end)

-- Deteccion de uso de Runas con click o hotkey
onUseWith(function(pos, itemId, target, subType)
  if not config.enabled then return end
  local rInfo = RuneItems[itemId]
  if rInfo then
    addOrUpdateCooldown({
      key = "rune_" .. itemId,
      type = "rune",
      runeId = itemId,
      name = rInfo.name,
      duration = rInfo.duration or 2000
    })
  end
end)

-- Callback oficial del cliente cuando entra un Cooldown
if onSpellCooldown then
  onSpellCooldown(function(iconId, duration)
    if not config.enabled then return end
    local nowMs = now or (os.time() * 1000)

    -- Si acabamos de hablar un spell hace menos de 300 ms, ajustar su duracion exacta
    if lastSpokenSpell and (nowMs - lastSpokenTime < 350) then
      for _, c in ipairs(activeCooldowns) do
        if c.key == ("spell_" .. lastSpokenSpell) then
          c.duration = duration
          c.endTime = c.startTime + duration
          c.iconId = iconId
          return
        end
      end
    end

    -- Si fue lanzado por actionbar / hotkey nativo
    addOrUpdateCooldown({
      key = "icon_" .. iconId,
      type = "spell",
      iconId = iconId,
      name = "Spell " .. iconId,
      duration = duration
    })
  end)
end

-- Creacion y Posicionamiento del Widget en Pantalla
local function createOrUpdateHud()
  local gameMapPanel = modules.game_interface and modules.game_interface.getMapPanel()
  if not gameMapPanel then return end

  if not hudWidget then
    local old = gameMapPanel:getChildById("cooldownHudFloating")
    if old then old:destroy() end

    hudWidget = g_ui.createWidget("CooldownHudWidget", gameMapPanel)
    hudWidget:setId("cooldownHudFloating")
    hudWidget.botWidget = true

    slots = {
      hudWidget.slot1,
      hudWidget.slot2,
      hudWidget.slot3,
      hudWidget.slot4,
      hudWidget.slot5,
      hudWidget.slot6
    }
  end

  local opac = math.min(1.0, math.max(0.1, (config.opacity or 20) / 100))
  hudWidget:setOpacity(opac)
  hudWidget:setVisible(config.enabled)

  -- Posicion inicial centrada sobre el personaje
  local offsetX = (config.pos and config.pos.x) or 0
  local offsetY = (config.pos and config.pos.y) or -75
  hudWidget:setMarginLeft(offsetX)
  hudWidget:setMarginTop(offsetY)

  -- Arrastre con Ctrl
  hudWidget.onDragEnter = function(self, mousePos)
    if config.lockPosition and not g_keyboard.isCtrlPressed() then
      return false
    end
    self.movingReference = { x = mousePos.x - self:getX(), y = mousePos.y - self:getY() }
    self.isBeingDragged = true
    return true
  end

  hudWidget.onDragLeave = function(self)
    self.isBeingDragged = false
    return true
  end

  hudWidget.onDragMove = function(self, mousePos, moved)
    local parent = self:getParent()
    if not parent then return false end
    local parentRect = parent:getRect()
    local centerX = parentRect.x + (parentRect.width / 2)
    local centerY = parentRect.y + (parentRect.height / 2)

    local newX = mousePos.x - self.movingReference.x
    local newY = mousePos.y - self.movingReference.y

    local relX = newX - centerX + (self:getWidth() / 2)
    local relY = newY - centerY + (self:getHeight() / 2)

    self:setMarginLeft(relX)
    self:setMarginTop(relY)
    config.pos = { x = relX, y = relY }
    return true
  end
end

createOrUpdateHud()
schedule(400, function()
  createOrUpdateHud()
end)

-- Macro ciclica de actualizacion (cada 50 ms)
-- Gestiona la desaparicion inmediata cuando expira el cooldown
macro(50, function()
  if not config.enabled or not hudWidget then return end
  local nowMs = now or (os.time() * 1000)

  -- 1. Limpiar entradas expiradas
  for i = #activeCooldowns, 1, -1 do
    local c = activeCooldowns[i]
    local rem = c.endTime - nowMs

    -- Verificar por tiempo o por estado oficial del icono
    local isExpired = (rem <= 0)
    if not isExpired and c.iconId and modules.game_cooldown and (nowMs - c.startTime > 300) then
      local active = modules.game_cooldown.isCooldownIconActive(c.iconId)
      if active == false then
        isExpired = true
      end
    end

    if isExpired then
      table.remove(activeCooldowns, i)
    end
  end

  -- 2. Actualizar los 6 slots visuales del cuadro 2x3
  local spellSource = "/images/game/spells/spell-icons-32x32"

  for i = 1, 6 do
    local slot = slots[i]
    if slot then
      local c = activeCooldowns[i]
      if c then
        slot:show()
        local remSec = math.max(0, (c.endTime - nowMs) / 1000)

        if c.type == "rune" then
          slot.spellIcon:hide()
          slot.runeItem:show()
          slot.runeItem:setItemId(c.runeId or 3155)
        else
          slot.runeItem:hide()
          slot.spellIcon:show()
          slot.spellIcon:setImageSource(spellSource)
          slot.spellIcon:setImageClip(getSpellClip(c.iconId or 1))
        end

        if config.showTimer and remSec > 0 then
          slot.timerLabel:setText(string.format("%.1f", remSec))
        else
          slot.timerLabel:setText("")
        end
      else
        slot:hide()
      end
    end
  end

  -- Si no hay ningun cooldown activo, ocultar fondo para máxima limpieza
  if #activeCooldowns == 0 then
    hudWidget:setBorderColor("#00000000")
    hudWidget:setBackgroundColor("#00000000")
  else
    hudWidget:setBorderColor("#3b82f622")
    hudWidget:setBackgroundColor("#00000022")
  end
end)

-- Panel de Configuracion en la pestana "Iconos"
UI.Separator()
local ui = setupUI([[
Panel
  height: 195

  Label
    text-align: center
    text: Cooldown HUD (Cuadro 2x3)
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    font: verdana-11px-rounded

  BotSwitch
    id: enabledSwitch
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4
    text: Activar HUD de Cooldowns 2x3
    height: 20

  Panel
    id: rowOpacity
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    height: 22

    Label
      text: Visibilidad:
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
      id: opacityInput
      anchors.right: prev.left
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 4
      width: 44
      font: verdana-11px-rounded
      text-align: center

  BotSwitch
    id: lockSwitch
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    text: Bloquear Pos (Ctrl+Arrastrar)
    height: 18

  BotSwitch
    id: timerSwitch
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 4
    text: Mostrar Temporizador Numerico
    height: 18

  Button
    id: centerBtn
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    margin-right: 2
    margin-top: 6
    height: 22
    text: Centrar HUD
    font: cipsoftFont

  Button
    id: demoBtn
    anchors.top: prev.top
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    margin-left: 2
    height: 22
    text: Probar 5 Iconos
    font: cipsoftFont
]])

ui.enabledSwitch:setOn(config.enabled)
ui.enabledSwitch.onClick = function(widget)
  config.enabled = not config.enabled
  widget:setOn(config.enabled)
  createOrUpdateHud()
end

ui.rowOpacity.opacityInput:setText(tostring(config.opacity or 20))
ui.rowOpacity.opacityInput.onTextChange = function(widget, text)
  local num = tonumber(text)
  if num and num >= 10 and num <= 100 then
    config.opacity = num
    createOrUpdateHud()
  end
end

ui.lockSwitch:setOn(config.lockPosition)
ui.lockSwitch.onClick = function(widget)
  config.lockPosition = not config.lockPosition
  widget:setOn(config.lockPosition)
end

ui.timerSwitch:setOn(config.showTimer)
ui.timerSwitch.onClick = function(widget)
  config.showTimer = not config.showTimer
  widget:setOn(config.showTimer)
end

ui.centerBtn.onClick = function()
  config.pos = { x = 0, y = -75 }
  if hudWidget then
    hudWidget:setMarginLeft(0)
    hudWidget:setMarginTop(-75)
  end
end

-- Demostracion con los 5 iconos del usuario para probar al instante
ui.demoBtn.onClick = function()
  local nowMs = now or (os.time() * 1000)
  activeCooldowns = {
    { key = "demo_1", type = "spell", iconId = 117, name = "Terra Wave", duration = 4000, startTime = nowMs, endTime = nowMs + 4000 },
    { key = "demo_2", type = "rune", runeId = 3161, name = "Avalanche", duration = 2000, startTime = nowMs, endTime = nowMs + 2000 },
    { key = "demo_3", type = "spell", iconId = 44, name = "Magic Shield", duration = 5000, startTime = nowMs, endTime = nowMs + 5000 },
    { key = "demo_4", type = "spell", iconId = 6, name = "Haste", duration = 2500, startTime = nowMs, endTime = nowMs + 2500 },
    { key = "demo_5", type = "rune", runeId = 3155, name = "SD", duration = 3000, startTime = nowMs, endTime = nowMs + 3000 }
  }
end
