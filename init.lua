--- === ShortcutsLogger ===
---
--- A spoon that log your shortcuts usages
---

local obj={}
obj.__index = obj

-- Metadata
obj.name = "wd"
obj.version = "0.1"
obj.author = "wd <wd@wdicc.com>"
obj.homepage = "https://github.com/wd/ShortcutsLogger.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local shortCuts = {
  ["keys"] = {},
  ["apps"] = {}
}

obj.keyPress = function(event)
  local flags = event:getFlags()
  local keycode = event:getKeyCode()
  local char = hs.keycodes.map[keycode]
  local win = hs.window.focusedWindow()
  if win == nil then
    return
  end

  local app = win:application()

  local keys = {}
  local shouldIgnore = true
  for i, v in ipairs{"cmd", "alt", "shift", "ctrl"} do
    if flags[v] then
      table.insert(keys, v)
      if v ~= "shift" then
        shouldIgnore = false
      end
    end
  end

  if shouldIgnore then
    return
  end

  table.insert(keys, char)
  keys = table.concat(keys, "+")

  local bundleId = "Unknown"
  if app then
    bundleId = app:bundleID()
  end


  if shortCuts["keys"][keys] == nil then
    shortCuts["keys"][keys] = 0
  end


  if shortCuts["apps"][bundleId] == nil then
    shortCuts["apps"][bundleId] = {}
  end

  if shortCuts["apps"][bundleId][keys] == nil then
    shortCuts["apps"][bundleId][keys] = 0
  end

  shortCuts["keys"][keys] = shortCuts["keys"][keys] + 1
  shortCuts["apps"][bundleId][keys] = shortCuts["apps"][bundleId][keys] + 1

end

obj.init = function()
  obj.eventTap = hs.eventtap.new({hs.eventtap.event.types.keyUp}, obj.keyPress)
end

obj.start = function()
  obj.eventTap:start()
end

local sortIt = function(t)
  local sorted = {}
  for k,v in pairs(t) do
    table.insert(sorted, {k, v})
  end
  table.sort(sorted, function(a,b) return a[2] > b[2] end)
  return sorted
end

obj.showShortCuts = function()
  local outputs = "ShortcutsLogger: statics>>\n\n"
  outputs = outputs .. "total ->\n"
  local keys = shortCuts["keys"]
  for _, v in ipairs(sortIt(keys)) do
    outputs = outputs .. string.format("  %s => %s\n", v[1], v[2])
  end

  outputs = outputs .. "\n"

  for app, keys in pairs(shortCuts["apps"]) do
    outputs = outputs .. app .. " ->\n"
    for _, v in pairs(sortIt(keys)) do
      outputs = outputs .. string.format("  %s => %s\n", v[1], v[2])
    end
  end
  hs.printf("\n\n%s\n\n", outputs)
end

return obj
