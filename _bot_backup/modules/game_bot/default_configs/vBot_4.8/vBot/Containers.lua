setDefaultTab("Tools")
local panelName = "renameContainers"

if type(storage[panelName]) ~= "table" then
    storage[panelName] = {
        enabled = false,
        height = 300,
        purse = false,
        sort = false,
        forceOpen = true,
        lootBag = false,
        list = {
            {
                value = "Main",
                enabled = true,
                item = 9601,
                min = false,
                openNext = false,
                items = { 3081, 3048 }
            },
            {
                value = "pociones",
                enabled = true,
                item = 2866,
                min = false,
                openNext = false,
                items = { 3161, 3180 }
            },
            {
                value = "Flechas",
                enabled = true,
                item = 2871,
                min = false,
                openNext = false,
                items = { 3031, 3035, 3043 }
            }
        }
    }
end

local config = storage[panelName]
if config.enabled == nil then config.enabled = false end
if config.purse == nil then config.purse = false end
if config.sort == nil then config.sort = false end
if config.forceOpen == nil then config.forceOpen = true end
if config.lootBag == nil then config.lootBag = false end
if not config.height or config.height < 220 then config.height = 300 end
if type(config.list) ~= "table" then config.list = {} end

UI.Separator()
local renameContui = setupUI([[
Panel
  height: 50

  Label
    text-align: center
    text: Container Panel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    font: verdana-11px-rounded

  BotSwitch
    id: title
    anchors.top: prev.bottom
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Auto Open BPs')
    font: verdana-11px-rounded

  Button
    id: editContList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
    font: verdana-11px-rounded

  Button
    id: reopenCont
    !text: tr('Reopen All')
    anchors.left: parent.left
    anchors.top: prev.bottom
    anchors.right: parent.horizontalCenter
    margin-right: 2
    height: 17
    margin-top: 3
    font: verdana-11px-rounded

  Button
    id: minimiseCont
    !text: tr('Minimise All')
    anchors.top: prev.top
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    margin-right: 2
    height: 17
    font: verdana-11px-rounded
  ]])
renameContui:setId(panelName)

g_ui.loadUIFromString([[
BackpackName < Panel
  background-color: alpha
  focusable: true
  height: 22

  $focus:
    background-color: #ffffff22

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-left: 2

  Label
    id: title
    anchors.left: prev.right
    anchors.right: upBtn.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 4
    margin-right: 4
    text-auto-resize: false
    font: verdana-11px-rounded

  Button
    id: upBtn
    !text: tr('^')
    !tooltip: tr('Subir orden (abrir antes)')
    anchors.right: downBtn.left
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 2
    width: 16
    height: 16

  Button
    id: downBtn
    !text: tr('v')
    !tooltip: tr('Bajar orden (abrir despues)')
    anchors.right: state.left
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 2
    width: 16
    height: 16

  Button
    id: state
    !text: tr('M')
    !tooltip: tr('Minimizar al abrir')
    anchors.right: openNext.left
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 2
    width: 16
    height: 16

  Button
    id: openNext
    !text: tr('N')
    !tooltip: tr('Abrir sub-mochila del mismo tipo adentro')
    anchors.right: remove.left
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 2
    width: 16
    height: 16

  Button
    id: remove
    !text: tr('X')
    !tooltip: tr('Eliminar de la lista')
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 14
    width: 16
    height: 16

ContListsWindow < MainWindow
  !text: tr('Configurar Mochilas (Orden de Apertura)')
  size: 530 300
  @onEscape: self:hide()

  Label
    id: listTitle
    anchors.left: parent.left
    anchors.top: parent.top
    text: Lista de Mochilas (se abren en este orden):
    font: verdana-11px-rounded
    margin-left: 3

  TextList
    id: itemList
    anchors.left: parent.left
    anchors.top: prev.bottom
    anchors.bottom: separator.top
    width: 270
    margin-bottom: 6
    margin-top: 5
    margin-left: 3
    vertical-scrollbar: itemListScrollBar

  VerticalScrollBar
    id: itemListScrollBar
    anchors.top: itemList.top
    anchors.bottom: itemList.bottom
    anchors.right: itemList.right
    step: 14
    pixels-scroll: true

  VerticalSeparator
    id: sep
    anchors.top: parent.top
    anchors.left: itemList.right
    anchors.bottom: separator.top
    margin-top: 3
    margin-bottom: 6
    margin-left: 10

  Label
    id: lblName
    anchors.left: sep.right
    anchors.top: parent.top
    width: 75
    text: Nombre BP:
    margin-left: 10
    margin-top: 5
    font: verdana-11px-rounded

  TextEdit
    id: contName
    anchors.left: lblName.right
    anchors.top: lblName.top
    anchors.right: parent.right
    font: verdana-11px-rounded

  Label
    id: lblCont
    anchors.left: lblName.left
    anchors.verticalCenter: contId.verticalCenter
    width: 75
    text: Mochila:
    font: verdana-11px-rounded

  BotItem
    id: contId
    anchors.left: contName.left
    anchors.top: contName.bottom
    margin-top: 6

  Label
    id: lblIdText
    anchors.left: contId.right
    anchors.verticalCenter: contId.verticalCenter
    margin-left: 10
    text: O escribe ID:
    font: verdana-11px-rounded

  TextEdit
    id: contIdInput
    anchors.left: prev.right
    anchors.verticalCenter: contId.verticalCenter
    anchors.right: parent.right
    margin-left: 5
    width: 65
    font: verdana-11px-rounded

  Button
    id: addItem
    anchors.right: parent.right
    anchors.top: contId.bottom
    margin-top: 8
    text: + Guardar Mochila
    width: 130
    height: 22
    font: cipsoftFont

  HorizontalSeparator
    id: sepItems
    anchors.left: sep.right
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 8
    margin-left: 10

  Label
    id: lblSortItems
    anchors.left: sep.right
    anchors.top: prev.bottom
    margin-top: 6
    margin-left: 10
    text: Items a ordenar aqui:
    font: verdana-11px-rounded

  BotContainer
    id: sortList
    anchors.left: sep.right
    anchors.right: parent.right
    anchors.top: prev.bottom
    anchors.bottom: separator.top
    margin-left: 10
    margin-bottom: 6
    margin-top: 4

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  CheckBox
    id: purse
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    text: Open Purse
    tooltip: Abre la Store / Charm Purse automaticamente
    width: 90
    height: 16
    margin-left: 3
    font: verdana-11px-rounded

  CheckBox
    id: forceOpen
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Keep Open
    tooltip: Si una mochila se cierra, la vuelve a abrir
    width: 90
    height: 16
    margin-left: 12
    font: verdana-11px-rounded

  CheckBox
    id: sort
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Sort Items
    tooltip: Ordena items a sus mochilas correspondientes
    width: 90
    height: 16
    margin-left: 12
    font: verdana-11px-rounded

  Button
    id: closeButton
    !text: tr('Cerrar')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 55 21
]])

function findItemsInArray(t, tfind)
    if type(t) ~= "table" then return tfind and nil or {} end
    local tArray = {}
    for x, v in pairs(t) do
        if type(v) == "table" then
            local aItem = v.item
            local aEnabled = v.enabled
            if aItem then
                if tfind and aItem == tfind then
                    return x
                elseif not tfind then
                    if aEnabled then
                        table.insert(tArray, aItem)
                    end
                end
            end
        end
    end
    if not tfind then return tArray end
    return nil
end

local function properTable(t)
    local r = {}
    if type(t) ~= "table" then return r end
    for _, entry in pairs(t) do
        if type(entry) == "number" then
            table.insert(r, entry)
        elseif type(entry) == "table" and entry.id then
            table.insert(r, entry.id)
        end
    end
    return r
end

local function moveItem(item, destination)
    if not item or not destination then return end
    return g_game.move(item, destination:getSlotPosition(destination:getItemsCount()), item:getCount())
end

local function isContainerOpen(id)
    if not id or id <= 0 then return false end
    for _, c in pairs(getContainers()) do
        local ci = c:getContainerItem()
        if ci and ci:getId() == id then
            return true
        end
    end
    return false
end

local function isBackOpen()
    local back = getBack()
    if not back then return false end
    for _, c in pairs(getContainers()) do
        local ci = c:getContainerItem()
        if ci and ci:getId() == back:getId() then
            return true
        end
    end
    return false
end

local lastActionTime = 0
local function checkAndOpenNextContainer()
    if not g_game.isOnline() then return false end
    if not config.enabled then return false end

    local currentNow = now or (os.time() * 1000)
    if currentNow < lastActionTime + 350 then
        return false
    end

    -- 1. Main backpack on player (SlotBack)
    local back = getBack()
    if back and not isBackOpen() then
        lastActionTime = currentNow
        g_game.open(back)
        return true
    end

    -- 2. Open Purse if enabled
    if config.purse and not isContainerOpen(23396) then
        local purse = getPurse()
        if purse then
            lastActionTime = currentNow
            use(purse)
            return true
        end
    end

    -- 3. Configured backpacks in EXACT list order
    if config.list and #config.list > 0 then
        for _, entry in ipairs(config.list) do
            if entry.enabled and entry.item and entry.item > 100 then
                local isOpen = isContainerOpen(entry.item)
                if not isOpen then
                    -- Search in body slots (right, left, ammo)
                    local slots = {getRight(), getLeft(), getAmmo()}
                    for _, slotItem in ipairs(slots) do
                        if slotItem and slotItem:getId() == entry.item then
                            lastActionTime = currentNow
                            g_game.open(slotItem)
                            return true
                        end
                    end

                    -- Search in open containers
                    for _, c in pairs(getContainers()) do
                        for _, it in ipairs(c:getItems()) do
                            if it:getId() == entry.item then
                                lastActionTime = currentNow
                                g_game.open(it)
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    -- 4. Gunzodus Loot Bag (if configured)
    if config.lootBag and not isContainerOpen(23721) then
        local purseCont = getContainerByItem(23396)
        if purseCont then
            for _, it in ipairs(purseCont:getItems()) do
                if it:getId() == 23721 then
                    lastActionTime = currentNow
                    g_game.open(it)
                    return true
                end
            end
        elseif config.purse then
            local purse = getPurse()
            if purse then
                lastActionTime = currentNow
                use(purse)
                return true
            end
        end
    end

    return false
end

function reopenBackpacks()
    for _, container in pairs(getContainers()) do
        g_game.close(container)
    end

    schedule(350, function()
        local back = getBack()
        if back then
            g_game.open(back)
        end
        if config.purse then
            schedule(200, function()
                local purse = getPurse()
                if purse then use(purse) end
            end)
        end
        schedule(500, function()
            checkAndOpenNextContainer()
        end)
    end)
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
    contListWindow = UI.createWindow('ContListsWindow', rootWidget)
    contListWindow:hide()

    if not config.height or config.height < 220 then
        config.height = 300
    end
    contListWindow:setHeight(config.height)
    contListWindow:setWidth(530)

    contListWindow.onGeometryChange = function(widget, old, new)
        if new.height >= 220 then
            config.height = new.height
        end
    end

    renameContui.editContList.onClick = function(widget)
        if not contListWindow:isVisible() then
            contListWindow:show()
            contListWindow:raise()
            contListWindow:focus()
            refreshContNames()
        else
            contListWindow:hide()
        end
    end

    renameContui.reopenCont.onClick = function(widget)
        reopenBackpacks()
    end

    renameContui.minimiseCont.onClick = function(widget)
        for i, container in ipairs(getContainers()) do
            if container.window then
                container.window:setContentHeight(34)
            end
        end
    end

    renameContui.title:setOn(config.enabled)
    renameContui.title.onClick = function(widget)
        config.enabled = not config.enabled
        widget:setOn(config.enabled)
        if config.enabled then
            checkAndOpenNextContainer()
        end
    end

    contListWindow.closeButton.onClick = function(widget)
        contListWindow:hide()
    end

    contListWindow.purse.onClick = function(widget)
        config.purse = not config.purse
        contListWindow.purse:setChecked(config.purse)
    end
    contListWindow.purse:setChecked(config.purse)

    contListWindow.sort.onClick = function(widget)
        config.sort = not config.sort
        contListWindow.sort:setChecked(config.sort)
    end
    contListWindow.sort:setChecked(config.sort)

    contListWindow.forceOpen.onClick = function(widget)
        config.forceOpen = not config.forceOpen
        contListWindow.forceOpen:setChecked(config.forceOpen)
    end
    contListWindow.forceOpen:setChecked(config.forceOpen)
    
    contListWindow.lootBag.onClick = function(widget)
        config.lootBag = not config.lootBag
        contListWindow.lootBag:setChecked(config.lootBag)
    end
    contListWindow.lootBag:setChecked(config.lootBag)

    local currentSelectedIndex = nil

    local function refreshSortList(k, t)
        t = t or {}
        UI.Container(function()
            t = contListWindow.sortList:getItems()
            if k and config.list and config.list[k] then
                config.list[k].items = t
            end
        end, true, nil, contListWindow.sortList) 
        contListWindow.sortList:setItems(t)
    end

    refreshContNames = function(tFocus)
        local storageVal = config.list
        contListWindow.itemList:destroyChildren()
        if storageVal and #storageVal > 0 then
            for k, entry in ipairs(storageVal) do
                local row = g_ui.createWidget("BackpackName", contListWindow.itemList)
                local displayText = string.format("#%d. %s (%d)", k, entry.value or "BP", entry.item or 0)
                row.title:setText(displayText)

                row.onMouseRelease = function()
                    currentSelectedIndex = k
                    contListWindow.contId:setItemId(entry.item or 0)
                    contListWindow.contIdInput:setText(tostring(entry.item or 0))
                    contListWindow.contName:setText(entry.value or "")
                    if not entry.items then
                        entry.items = {}
                    end
                    refreshSortList(k, entry.items)
                end

                row.enabled.onClick = function(widget)
                    entry.enabled = not entry.enabled
                    row.enabled:setChecked(entry.enabled)
                    row.enabled:setTooltip(entry.enabled and 'Desactivar mochila' or 'Activar mochila')
                    row.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                end

                row.upBtn.onClick = function()
                    if k > 1 then
                        local temp = config.list[k]
                        config.list[k] = config.list[k - 1]
                        config.list[k - 1] = temp
                        refreshContNames(temp.item)
                    end
                end

                row.downBtn.onClick = function()
                    if k < #config.list then
                        local temp = config.list[k]
                        config.list[k] = config.list[k + 1]
                        config.list[k + 1] = temp
                        refreshContNames(temp.item)
                    end
                end

                row.state:setChecked(entry.min or false)
                row.state.onClick = function(widget)
                    entry.min = not entry.min
                    row.state:setChecked(entry.min)
                    row.state:setColor(entry.min and '#00FF00' or '#FF0000')
                    row.state:setTooltip(entry.min and 'Abrir Minimizada' or 'Abrir Normal')
                end

                row.openNext:setChecked(entry.openNext or false)
                row.openNext.onClick = function(widget)
                    entry.openNext = not entry.openNext
                    row.openNext:setChecked(entry.openNext)
                    row.openNext:setColor(entry.openNext and '#00FF00' or '#FF0000')
                end

                row.remove.onClick = function(widget)
                    table.remove(config.list, k)
                    refreshContNames()
                end

                row.enabled:setChecked(entry.enabled)
                row.enabled:setTooltip(entry.enabled and 'Desactivar mochila' or 'Activar mochila')
                row.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                row.state:setColor(entry.min and '#00FF00' or '#FF0000')
                row.state:setTooltip(entry.min and 'Abrir Minimizada' or 'Abrir Normal')
                row.openNext:setColor(entry.openNext and '#00FF00' or '#FF0000')

                if tFocus and entry.item == tFocus then
                    tFocus = row
                end
            end
            if tFocus and type(tFocus) ~= "number" then contListWindow.itemList:focusChild(tFocus) end
        end
    end

    contListWindow.contId.onItemChange = function(widget)
        local itemId = widget:getItemId()
        if itemId > 0 then
            contListWindow.contIdInput:setText(tostring(itemId))
        end
    end

    contListWindow.contIdInput.onTextChange = function(widget, text)
        local num = tonumber(text)
        if num and num > 0 and num ~= contListWindow.contId:getItemId() then
            contListWindow.contId:setItemId(num)
        end
    end

    contListWindow.addItem.onClick = function(widget)
        local id = contListWindow.contId:getItemId()
        local inputId = tonumber(contListWindow.contIdInput:getText())
        if (not id or id <= 100) and inputId and inputId > 100 then
            id = inputId
        end
        local trigger = contListWindow.contName:getText()

        if id and id > 100 then
            if not trigger or trigger:len() == 0 then
                trigger = "BP " .. tostring(id)
            end
            local ifind = findItemsInArray(config.list, id)
            if ifind then
                config.list[ifind].item = id
                config.list[ifind].value = trigger
            else
                table.insert(config.list, { item = id, value = trigger, enabled = true, min = false, openNext = false, items = {} })
            end
            contListWindow.contId:setItemId(0)
            contListWindow.contIdInput:setText('')
            contListWindow.contName:setText('')
            contListWindow.contName:setColor('white')
            contListWindow.contName:setImageColor('#ffffff')
            contListWindow.contId:setImageColor('#ffffff')
            refreshContNames(id)
        else
            contListWindow.contId:setImageColor('red')
            contListWindow.contName:setImageColor('red')
            contListWindow.contName:setColor('red')
        end
    end

    refreshContNames()
end

onContainerOpen(function(container, previousContainer)
    if not container or not container.window then return end
    local containerWindow = container.window
    local cItem = container:getContainerItem()
    local cId = cItem and cItem:getId() or nil

    if cId and config.list and #config.list > 0 then
        for _, entry in pairs(config.list) do
            if entry.enabled and entry.item == cId then
                if entry.min then
                    containerWindow:minimize()
                end
                if entry.value and #entry.value > 0 then
                    containerWindow:setText(entry.value)
                end
                if entry.openNext then
                    for i, item in ipairs(container:getItems()) do
                        if item:getId() == entry.item then
                            schedule(250, function()
                                g_game.open(item)
                            end)
                            break
                        end
                    end
                end
                break
            end
        end
    end

    if config.enabled then
        schedule(200, function()
            checkAndOpenNextContainer()
        end)
    end
end)

local function nameContainersOnLogin()
    if not config.list or #config.list == 0 then return end
    for i, container in ipairs(getContainers()) do
        local cItem = container:getContainerItem()
        local cId = cItem and cItem:getId() or nil
        if cId and container.window then
            for _, entry in pairs(config.list) do
                if entry.enabled and entry.item == cId then
                    if entry.value and #entry.value > 0 then
                        container.window:setText(entry.value)
                    end
                    if entry.min then
                        container.window:minimize()
                    end
                    break
                end
            end
        end
    end
end
nameContainersOnLogin()

local mainLoop = macro(350, function()
    if not g_game.isOnline() then return end

    -- 1. Auto open BPs if enabled
    if config.enabled then
        checkAndOpenNextContainer()
    end

    -- 2. Sort items if enabled
    if config.sort and config.list and #config.list > 0 then
        for _, entry in pairs(config.list) do
            if entry.enabled and entry.items and #entry.items > 0 then
                local dId = entry.item
                local items = properTable(entry.items)
                for _, container in pairs(getContainers()) do
                    local cName = container:getName():lower()
                    local cItem = container:getContainerItem()
                    local cId = cItem and cItem:getId() or 0
                    if not cName:find("depot") and not cName:find("quiver") and cId ~= dId then
                        for _, item in ipairs(container:getItems()) do
                            if table.find(items, item:getId()) then
                                local destination = getContainerByItem(dId, true)
                                if destination and not containerIsFull(destination) then
                                    return moveItem(item, destination)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

onContainerClose(function(container)
    if config.enabled and config.forceOpen then
        schedule(250, function()
            checkAndOpenNextContainer()
        end)
    end
end)