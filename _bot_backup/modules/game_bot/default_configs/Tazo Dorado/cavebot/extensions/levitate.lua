UI.Label("Auto Follow")


addTextEdit("followleader", storage.followLeader or "player name", function(widget, text)
  storage.followLeader = text
end)


--Code
local toFollowPos = {}
local followMacro = macro(20, "Follow", function()
  local target = getCreatureByName(storage.followLeader)
  if target then
    local tpos = target:getPosition()
    toFollowPos[tpos.z] = tpos
  end


  if player:isWalking() then return end
  local p = toFollowPos[posz()]
  if not p then return end


  if autoWalk(p, 20, {ignoreNonPathable=false, precision=2, marginMin=1, marginMax=2}) then
    delay(100)
  end
end)


onCreaturePositionChange(function(creature, oldPos, newPos)
  if creature:getName() == storage.followLeader then
    toFollowPos[newPos.z] = newPos
  end
end)


UI.Separator()