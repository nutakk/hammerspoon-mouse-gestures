local backButton, threshold = 3, 60
local startPos = nil

local function sendCtrlArrow(dir)
  local codes = { left=123, right=124, down=125, up=126 }
  hs.osascript.applescript(
    ('tell application "System Events" to key code %d using control down'):format(codes[dir])
  )
end

local function decideAndTrigger(endPos)
  local dx, dy = endPos.x - startPos.x, endPos.y - startPos.y
  if (dx*dx + dy*dy)^0.5 < threshold then return end
  local a = math.deg(math.atan2(dy, dx))
  if a > 180 then a = a - 360 elseif a < -180 then a = a + 360 end
  if a >= -45 and a <= 45 then sendCtrlArrow("right")
  elseif a >= 135 or a <= -135 then sendCtrlArrow("left")
  elseif a > 45 and a < 135 then sendCtrlArrow("down")
  elseif a < -45 and a > -135 then sendCtrlArrow("up") end
end

hs.eventtap.new(
  { hs.eventtap.event.types.otherMouseDown, hs.eventtap.event.types.otherMouseUp },
  function(e)
    if e:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) ~= backButton then return false end
    if e:getType() == hs.eventtap.event.types.otherMouseDown then
      startPos = hs.mouse.absolutePosition()
    elseif e:getType() == hs.eventtap.event.types.otherMouseUp then
      decideAndTrigger(hs.mouse.absolutePosition())
      startPos = nil
    end
    return true
  end
):start()

hs.alert.show("Back-drag gesture (on release) loaded")
