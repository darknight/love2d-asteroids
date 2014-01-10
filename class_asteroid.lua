--[[ the asteroid class ]]

math.randomseed(os.time())

local t = {}
t.image = love.graphics.newImage("resources/asteroid.png")
t.width = t.image:getWidth()
t.height = t.image:getHeight()
t.x = 0
t.y = 0
t.dead = false
t.scale = 1
t.is_bullet = false

function t:new(obj)
    obj = obj or {}
    obj.rotation = math.random(360)
    obj.rotate_speed = math.random() * 100 - 50
    obj.velocity_x = love.math.random() * 40
    obj.velocity_y = love.math.random() * 40
    setmetatable(obj, self)
    self.__index = self
    return obj
end

return t
