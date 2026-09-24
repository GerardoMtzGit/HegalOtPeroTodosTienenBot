setDefaultTab("Tools")
local panelName = "renameContainers"

if type(storage[panelName]) ~= "table" then
    storage[panelName] = {
        enabled = false,
        height = 170,
        purse = false,
        sort = false,
        forceOpen = false,
        lootBag = false,
        list = {
            {
                value = "Main Backpack",
                enabled = true,
                item = 9601,
                min = false,
                openNext = false,
                items = { 3081, 3048 }
            },
            {
                value = "Runes",
                enabled = true,
                item = 2866,
                min = true,
                openNext = false,
                items = { 3161, 3180 }
            },
            {
                value = "Money",
                enabled = true,
                item = 2871,
                min = true,
                openNext = false,
                items = { 3031, 3035, 3043 }
            },
            {
                value = "Purse",
                enabled = true,
                item = 23396,
                min = true,
                openNext = false,
                items = {}
            }
        }
    }
end

local config = storage[panelName]
if config.enabled == nil then config.enabled = false end
if config.purse == nil then config.purse = false end
if config.sort == nil then config.sort = false end
if config.forceOpen == nil then config.forceOpen = false end
if config.lootBag == nil then config.lootBag = false end
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
BackpackName < Label
  background-color: alpha
  text-offset: 18 2
  focusable: true
  height: 17
  font: verdana-11px-rounded

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 1
    margin-left: 3

  $focus:
    background-color: #00000055

  Button
    id: state
    !text: tr('M')
    anchors.right: remove.left
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 1
    width: 15
    height: 15

  Button
    id: remove
    !text: tr('X')
    !tooltip: tr('Remove')
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 15
    width: 15
    height: 15

  Button
    id: openNext
    !text: tr('N')
    anchors.right: state.left
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 1
    width: 15
    height: 15
    tooltip: Open container inside with the same ID.

ContListsWindow < MainWindow
  !text: tr('Container Names & Auto Open')
  size: 465 170
  @onEscape: self:hide()

  TextList
    id: itemList
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: separator.top
    width: 200
    margin-bottom: 6
    margin-top: 3
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
    anchors.top: sep.top
    width: 70
    text: Name:
    margin-left: 10
    margin-top: 3
    font: verdana-11px-rounded

  TextEdit
    id: contName
    anchors.left: lblName.right
    anchors.top: sep.top
    anchors.right: parent.right
    font: verdana-11px-rounded

  Label
    id: lblCont
    anchors.left: lblName.left
    anchors.verticalCenter: contId.verticalCenter
    width: 70
    text: Container:
    font: verdana-11px-rounded

  BotItem
    id: contId
    anchors.left: contName.left
    anchors.top: contName.bottom
    margin-top: 3

  BotContainer
    id: sortList
    anchors.left: prev.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    anchors.bottom: separator.top
    margin-bottom: 6
    margin-top: 3

  Label
    anchors.left: lblCont.left
    anchors.verticalCenter: sortList.verticalCenter
    width: 70
    text: Items: 
    font: verdana-11px-rounded

  Button
    id: addItem
    anchors.right: contName.right
    anchors.top: contName.bottom
    margin-top: 5
    text: Add
    width: 40
    font: cipsoftFont

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
    tooltip: Opens Store/Charm Purse
    width: 85
    height: 15
    margin-top: 2
    margin-left: 3
    font: verdana-11px-rounded

  CheckBox
    id: sort
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Sort Items
    tooltip: Sort items based on items widget
    width: 85
    height: 15
    margin-top: 2
    margin-left: 15
    font: verdana-11px-rounded

  CheckBox
    id: forceOpen
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Keep Open
    tooltip: Will keep open containers all the time
    width: 85
    height: 15
    margin-top: 2
    margin-left: 15
    font: verdana-11px-rounded

  CheckBox
    id: lootBag
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Loot Bag
    tooltip: Open Loot Bag (gunzodus franchaise)
    width: 85
    height: 15
    margin-top: 2
    margin-left: 15
    font: verdana-11px-rounded

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15

  ResizeBorder
    id: bottomResizeBorder
    anchors.fill: separator
    height: 3
    minimum: 170
    maximum: 245
    margin-left: 3
    margin-right: 3
    background: #ffffff88
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

local function countOpenContainers(id)
    if not id or id <= 0 then return 0 end
    local count = 0
    for _, c in pairs(getContainers()) do
        local ci = c:getContainerItem()
        if ci and ci:getId() == id then
            count = count + 1
        end
    end
    return count
end

local lastActionTime = 0
local function checkAndOpenNextContainer()
    if not g_game.isOnline() then return false end
    if not config.enabled then return false end

    local now = g_clock.millis()
    if now < lastActionTime + 300 then
        return false
    end

    -- 1. Main backpack on player
    local back = getBack()
    if back and #getContainers() == 0 then
        lastActionTime = now
        g_game.open(back)
        return true
    end

    -- 2. Open Purse if enabled
    if config.purse and not isContainerOpen(23396) then
        local purse = getPurse()
        if purse then
            lastActionTime = now
            use(purse)
            return true
        end
    end

    -- 3. Configured backpacks in list
    if config.list and #config.list > 0 then
        for _, entry in ipairs(config.list) do
            if entry.enabled and entry.item and entry.item > 100 then
                local openCount = countOpenContainers(entry.item)
                if openCount == 0 then
                    -- Check body slots first (right, left, ammo)
                    local slots = {getRight(), getLeft(), getAmmo()}
                    for _, slotItem in ipairs(slots) do
                        if slotItem and slotItem:getId() == entry.item then
                            lastActionTime = now
                            g_game.open(slotItem, nil)
                            return true
                        end
                    end

                    -- Search in currently open containers
                    for _, c in pairs(getContainers()) do
                        for _, it in ipairs(c:getItems()) do
                            if it:isContainer() and it:getId() == entry.item then
                                lastActionTime = now
                                g_game.open(it, nil)
                                return true
                            end
                        end
                    end
                elseif entry.openNext then
                    -- If openNext is enabled, find nested containers of same ID inside open containers
                    for _, c in pairs(getContainers()) do
                        local ci = c:getContainerItem()
                        if ci and ci:getId() == entry.item then
                            for _, it in ipairs(c:getItems()) do
                                if it:isContainer() and it:getId() == entry.item then
                                    lastActionTime = now
                                    g_game.open(it, nil)
                                    return true
                                end
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
                    lastActionTime = now
                    g_game.open(it, nil)
                    return true
                end
            end
        elseif config.purse then
            local purse = getPurse()
            if purse then
                lastActionTime = now
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

    contListWindow.onGeometryChange = function(widget, old, new)
        if old.height == 0 then return end
        config.height = new.height
    end

    contListWindow:setHeight(config.height or 170)

    renameContui.editContList.onClick = function(widget)
        contListWindow:show()
        contListWindow:raise()
        contListWindow:focus()
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

    local refreshContNames = function(tFocus)
        local storageVal = config.list
        contListWindow.itemList:destroyChildren()
        if storageVal and #storageVal > 0 then
            for k, entry in pairs(storageVal) do
                local label = g_ui.createWidget("BackpackName", contListWindow.itemList)
                label.onMouseRelease = function()
                    currentSelectedIndex = k
                    contListWindow.contId:setItemId(entry.item or 0)
                    contListWindow.contName:setText(entry.value or "")
                    if not entry.items then
                        entry.items = {}
                    end
                    refreshSortList(k, entry.items)
                end
                label.enabled.onClick = function(widget)
                    entry.enabled = not entry.enabled
                    label.enabled:setChecked(entry.enabled)
                    label.enabled:setTooltip(entry.enabled and 'Disable' or 'Enable')
                    label.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                end
                label.remove.onClick = function(widget)
                    table.removevalue(config.list, entry)
                    label:destroy()
                end
                label.state:setChecked(entry.min or false)
                label.state.onClick = function(widget)
                    entry.min = not entry.min
                    label.state:setChecked(entry.min)
                    label.state:setColor(entry.min and '#00FF00' or '#FF0000')
                    label.state:setTooltip(entry.min and 'Open Minimised' or 'Do not minimise')
                end
                label.openNext:setChecked(entry.openNext or false)
                label.openNext.onClick = function(widget)
                    entry.openNext = not entry.openNext
                    label.openNext:setChecked(entry.openNext)
                    label.openNext:setColor(entry.openNext and '#00FF00' or '#FF0000')
                end
                label:setText(entry.value or ("BP " .. tostring(entry.item or 0)))
                label.enabled:setChecked(entry.enabled)
                label.enabled:setTooltip(entry.enabled and 'Disable' or 'Enable')
                label.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                label.state:setColor(entry.min and '#00FF00' or '#FF0000')
                label.state:setTooltip(entry.min and 'Open Minimised' or 'Do not minimise')
                label.openNext:setColor(entry.openNext and '#00FF00' or '#FF0000')

                if tFocus and entry.item == tFocus then
                    tFocus = label
                end
            end
            if tFocus and type(tFocus) ~= "number" then contListWindow.itemList:focusChild(tFocus) end
        end
    end

    contListWindow.addItem.onClick = function(widget)
        local id = contListWindow.contId:getItemId()
        local trigger = contListWindow.contName:getText()

        if id > 100 then
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
                                g_game.open(item, nil)
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
    if config.enabled then
        schedule(250, function()
            checkAndOpenNextContainer()
        end)
    end
end)