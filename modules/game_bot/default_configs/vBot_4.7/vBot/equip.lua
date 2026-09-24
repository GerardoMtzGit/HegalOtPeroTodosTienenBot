-- Auto Equip (HP Tab) - Anillos, Amuletos y Equipamiento Automatico
setDefaultTab("HP")
local scripts = 2 -- Panel 1: Neck (Amuletos/Collares), Panel 2: Finger (Anillos/Rings)

UI.Label("Auto equip")
if type(storage.autoEquip) ~= "table" then
  storage.autoEquip = {}
end

-- Pares de transformacion conocidos (desgastado <-> activo/usado)
local itemTransformPairs = {
  -- Rings
  [3049] = 3086, [3086] = 3049, -- Stealth Ring
  [3050] = 3087, [3087] = 3050, -- Power Ring
  [3051] = 3088, [3088] = 3051, -- Energy Ring
  [3052] = 3089, [3089] = 3052, -- Life Ring
  [3053] = 3090, [3090] = 3053, -- Time Ring
  [3091] = 3094, [3094] = 3091, -- Club Ring
  [3092] = 3095, [3095] = 3092, -- Sword Ring
  [3093] = 3096, [3096] = 3093, -- Axe Ring
  [3097] = 3099, [3099] = 3097, -- Dwarven Ring
  [3098] = 3100, [3100] = 3098, -- Ring of Healing
  [16114] = 16264, [16264] = 16114, -- Prismatic Ring
  [31621] = 31616, [31616] = 31621, -- Blister Ring
  [32621] = 32635, [32635] = 32621, -- Ring of Souls
  [23537] = 23543, [23543] = 23537, -- Ring of Blue Plasma
  [23535] = 23541, [23541] = 23535, -- Ring of Green Plasma
  [23539] = 23544, [23544] = 23539, -- Ring of Red Plasma

  -- Amulets / Necklaces
  [23531] = 23532, [23532] = 23531, -- Gill Necklace
  [23533] = 23534, [23534] = 23533, -- Prismatic Necklace
  [23529] = 23530, [23530] = 23529, -- Sun Catcher
  [30343] = 30342, [30342] = 30343, -- Sleep Shawl
  [30344] = 30345, [30345] = 30344, -- Enchanted Pendulet
  [30403] = 30402, [30402] = 30403, -- Enchanted Theurgic Amulet
  [23538] = 23542, [23542] = 23538, -- Collar of Blue Plasma
  [23536] = 23540, [23540] = 23536, -- Collar of Green Plasma
  [23540] = 23545, [23545] = 23540  -- Collar of Red Plasma
}

local function isMatching(itemId, target1, target2)
  if not itemId or itemId <= 0 then return false end
  local targets = {}
  local function add(t)
    if t and t > 0 then
      targets[t] = true
      if itemTransformPairs[t] then targets[itemTransformPairs[t]] = true end
      if getActiveItemId and getActiveItemId(t) then targets[getActiveItemId(t)] = true end
      if getInactiveItemId and getInactiveItemId(t) then targets[getInactiveItemId(t)] = true end
    end
  end
  add(target1)
  add(target2)
  return targets[itemId] == true
end

for i=1,scripts do
  if not storage.autoEquip[i] then
    storage.autoEquip[i] = {
      on = false,
      title = i == 1 and "Auto Equip Neck" or "Auto Equip Ring",
      item1 = i == 1 and 3081 or 3052,
      item2 = i == 1 and 0 or 3089,
      slot = i == 1 and 2 or 9
    }
  end

  -- Garantizar que el slot nunca quede en 0 o vacio (2=Neck, 9=Finger)
  if not storage.autoEquip[i].slot or storage.autoEquip[i].slot <= 0 then
    storage.autoEquip[i].slot = (i == 1 and 2 or 9)
  end

  -- Titulo descriptivo para identificar que equipa cada seccion
  if storage.autoEquip[i].title == "Auto Equip" or not storage.autoEquip[i].title then
    storage.autoEquip[i].title = (storage.autoEquip[i].slot == 2 and "Auto Equip Neck") or (storage.autoEquip[i].slot == 9 and "Auto Equip Ring") or "Auto Equip"
  end

  UI.TwoItemsAndSlotPanel(storage.autoEquip[i], function(widget, newParams)
    storage.autoEquip[i] = newParams
  end)
end

local lastMethod = {}

local function equipItemDirect(item, slot)
  if not item then return false end
  local itemId = (type(item) == "userdata" or type(item) == "table") and item:getId() or item

  -- En Tibia, los slots de cuerpo (cuello, anillo, etc.) solo aceptan count = 1.
  -- Si se envia count > 1 (por ejemplo, Stone Skin Amulet con 5 cargas o Might Ring con 20),
  -- el servidor rechaza el paquete de movimiento. Solo ammo (slot 10) acepta stackables > 1.
  local count = (slot == 10 and item.isStackable and item:isStackable() and item:getCount()) or 1

  local method = lastMethod[slot] or 1

  -- Metodo 1: Quick-equip nativo del protocolo (version >= 910)
  if method == 1 and g_game.getClientVersion and g_game.getClientVersion() >= 910 and g_game.equipItemId then
    local ok = pcall(function() g_game.equipItemId(itemId) end)
    lastMethod[slot] = 2
    if ok then return true end
  end

  -- Metodo 2: Mover directamente al slot con count = 1 (universal para todos los protocolos)
  pcall(function()
    g_game.move(item, {x = 65535, y = slot, z = 0}, count)
  end)
  lastMethod[slot] = 1

  return true
end

macro(250, function()
  for index, autoEquip in ipairs(storage.autoEquip) do
    if autoEquip.on and autoEquip.slot and autoEquip.slot > 0 then
      local id1 = autoEquip.item1 or 0
      local id2 = autoEquip.item2 or 0

      -- Procesar solo si hay al menos un item seleccionado en alguno de los dos slots
      if id1 > 0 or id2 > 0 then
        local slotItem = getSlot(autoEquip.slot)

        -- Si el slot no tiene el item deseado (o esta vacio o tiene un item diferente)
        if not slotItem or not isMatching(slotItem:getId(), id1, id2) then
          local itemToEquip = nil
          local containers = g_game.getContainers()

          -- 1. Buscar en mochilas abiertas
          for _, container in pairs(containers) do
            for __, item in ipairs(container:getItems()) do
              if isMatching(item:getId(), id1, id2) then
                itemToEquip = item
                break
              end
            end
            if itemToEquip then break end
          end

          -- 2. Respaldo por findItem si no se encontro en el primer barrido
          if not itemToEquip then
            if id1 > 0 and findItem(id1) then
              itemToEquip = findItem(id1)
            elseif id2 > 0 and findItem(id2) then
              itemToEquip = findItem(id2)
            end
          end

          if itemToEquip then
            equipItemDirect(itemToEquip, autoEquip.slot)
            delay(400) -- Evitar spam de paquetes
            return
          end
        end
      end
    end
  end
end)