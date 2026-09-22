-- walking
local expectedDirs = {}
local isWalking = false
local walkPath = {}
local walkPathIter = 0

CaveBot.resetWalking = function()
  expectedDirs = {}
  walkPath = {}
  isWalking = false
end

local function getWalkDelay(dir)
  local duration = player:getStepDuration(false, dir)
  local ping = CaveBot.Config.get("ping") or 0
  local walkDelay = CaveBot.Config.get("walkDelay") or 0
  -- Subtract server ping to pipeline walk packets so character runs fluidly without pausing
  return math.max(0, duration - ping + walkDelay)
end

CaveBot.doWalking = function()
  if CaveBot.Config.get("mapClick") then
    return false
  end
  if not isWalking or not walkPath or #walkPath == 0 then
    return false
  end
  if #expectedDirs >= 2 then
    return true
  end
  local dir = walkPath[walkPathIter]
  if dir then
    g_game.walk(dir, false)
    table.insert(expectedDirs, dir)
    walkPathIter = walkPathIter + 1
    CaveBot.delay(getWalkDelay(dir))
    return true
  end
  if #expectedDirs > 0 then
    return true
  end
  CaveBot.resetWalking()
  return false  
end

-- called when player position has been changed (step has been confirmed by server)
onPlayerPositionChange(function(newPos, oldPos)
  if not oldPos or not newPos then return end
  
  local dirs = {{NorthWest, North, NorthEast}, {West, 8, East}, {SouthWest, South, SouthEast}}
  local dir = dirs[newPos.y - oldPos.y + 2]
  if dir then
    dir = dir[newPos.x - oldPos.x + 2]
  end
  if not dir then
    dir = 8 -- 8 is invalid dir, it's fine
  end

  if newPos.z ~= oldPos.z then
    -- Floor change (stairs/ladder/teleport), clear walking state
    walkPath = {}
    expectedDirs = {}
    isWalking = false
    CaveBot.delay(CaveBot.Config.get("ping") + 50)
    return
  end

  if not isWalking or #expectedDirs == 0 then
    return
  end
  
  if expectedDirs[1] == dir then
    table.remove(expectedDirs, 1)  
    if CaveBot.Config.get("mapClick") and #expectedDirs > 0 then
      CaveBot.delay(CaveBot.Config.get("mapClickDelay"))
    end
  else
    CaveBot.resetWalking()
  end
end)

CaveBot.walkTo = function(dest, maxDist, params)
  local path = getPath(player:getPosition(), dest, maxDist, params)
  if not path or not path[1] then
    return false
  end
  local dir = path[1]
  
  if CaveBot.Config.get("mapClick") then
    local ret = autoWalk(path)
    if ret then
      isWalking = true
      expectedDirs = path
      CaveBot.delay(CaveBot.Config.get("mapClickDelay"))
    end
    return ret
  end
  
  g_game.walk(dir, false)
  isWalking = true    
  walkPath = path
  walkPathIter = 2
  expectedDirs = { dir }
  CaveBot.delay(getWalkDelay(dir))
  return true
end
