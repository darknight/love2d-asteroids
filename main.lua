player_ship = {} -- the player
score_label = "Score: 0"
level_label = "Version 2: Basic Motion"

love.math.setRandomSeed(os.time())

function distance(point1_x, point1_y, point2_x, point2_y)
    -- get distance of two points
    point1_x = point1_x or 0
    point1_y = point1_y or 0
    point2_x = point2_x or 0
    point2_y = point2_y or 0
    return math.sqrt((point1_x - point2_x) ^ 2 + (point1_y - point2_y) ^ 2)
end

function check_bounds(obj)
    min_x = -obj.width / 2
    min_y = -obj.height / 2
    max_x = 800 + obj.width / 2
    max_y = 600 + obj.height / 2
    if obj.x < min_x then
        obj.x = max_x
    elseif obj.x > max_x then
        obj.x = min_x
    end
    if obj.y < min_y then
        obj.y = max_y
    elseif obj.y > max_y then
        obj.y = min_y
    end
end

function update_obj(obj, dt)
    obj.x = obj.x + obj.velocity_x * dt
    obj.y = obj.y + obj.velocity_y * dt
    check_bounds(obj)
end

function load_asteroids(num_asteroids, player_x, player_y)
    -- load asteroid info, keep away from the player
    local asteroids = {}
    for i = 1, num_asteroids do
        local asteroid = { x = player_x, y = player_y }
        while distance(asteroid.x, asteroid.y, player_x, player_y) < 100 do
            asteroid.x = love.math.random(800)
            asteroid.y = love.math.random(600)
        end
        asteroid.image = love.graphics.newImage("resources/asteroid.png")
        asteroid.rotation = love.math.random(360)
        asteroid.width = asteroid.image:getWidth()
        asteroid.height = asteroid.image:getHeight()
        asteroid.velocity_x = love.math.random() * 40
        asteroid.velocity_y = love.math.random() * 40
        table.insert(asteroids, asteroid)
    end
    return asteroids
end

function update_asteroid(asteroid, dt)
    update_obj(asteroid, dt)
end

function load_player()
    local player = {}
    player.image = love.graphics.newImage("resources/player.png")
    player.x = 400
    player.y = 300
    player.width = player.image:getWidth()
    player.height = player.image:getHeight()
    player.velocity_x = 0
    player.velocity_y = 0
    player.thrust = 300
    player.rotate_speed = 200
    player.rotation = 0
    return player
end

function update_player(player, dt)
    update_obj(player, dt)
    if love.keyboard.isDown("up") then
        angle_radians = math.rad(player.rotation)
        force_x = math.cos(angle_radians) * player.thrust * dt
        force_y = math.sin(angle_radians) * player.thrust * dt
        player.velocity_x = player.velocity_x + force_x
        player.velocity_y = player.velocity_y + force_y
    end
    if love.keyboard.isDown("left") then
        player.rotation = player.rotation - player.rotate_speed * dt
    end
    if love.keyboard.isDown("right") then
        player.rotation = player.rotation + player.rotate_speed * dt
    end
end

function load_player_lives(num_icons)
    local image = love.graphics.newImage("resources/player.png")
    local sprite_batch = love.graphics.newSpriteBatch(image, num_icons)
    for i = 1, num_icons do
        sprite_batch:add(785-(i-1)*30, 15, 0, 0.5, 0.5, image:getWidth() / 2, image:getHeight() / 2, 0, 0)
    end
    return sprite_batch
end
-----------------------love function-----------------

function love.load()
    main_font = love.graphics.newFont(15)
    love.graphics.setFont(main_font)
    player_ship = load_player()
    asteroids = load_asteroids(3, player_ship.x, player_ship.y)
    player_lives = load_player_lives(2)
end

function love.draw()
    -- draw label
    local level_width = main_font:getWidth(level_label)
    love.graphics.print(score_label, 10, 25)
    love.graphics.printf(level_label, 400, 25, level_width, "left", 0, 1, 1, level_width / 2, 0, 0, 0)
    -- draw player ship
    love.graphics.draw(player_ship.image, player_ship.x, player_ship.y, math.rad(player_ship.rotation), 1, 1, 
                       player_ship.width / 2, player_ship.height / 2)
    -- draw asteroids
    for _, v in ipairs(asteroids) do
        love.graphics.draw(v.image, v.x, v.y, math.rad(v.rotation), 1, 1, v.width / 2, v.height / 2)
    end
    -- draw player lives in sprite batch
    love.graphics.draw(player_lives)
end

function love.update(dt)
    update_player(player_ship, dt)
    for _, v in ipairs(asteroids) do
        update_asteroid(v, dt)
    end
end
