--[[ the class of engine flame ]]

local t = {}
t.image = love.graphics.newImage("resources/engine_flame.png")
t.x = 0
t.y = 0
t.rotation = 0
t.visible = false
t.width = t.image:getWidth()
t.height = t.image:getHeight()

function t:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

return t
