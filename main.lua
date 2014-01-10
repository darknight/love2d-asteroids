local util = require("util")
local Engine = require("engine_class")
local Player = require("player_class")

score_label = "Score: "
level_label = "Version 5: It's a Game"
game_over_label = "GAME OVER"

score = 0
total_asteroids = 3

love.math.setRandomSeed(os.time())
math.randomseed(os.time())

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

function collide(obj1, obj2)
    -- only (bullet, asteroid) (player, asteroid) could collide
    if obj1.is_bullet == false and obj2.is_bullet == false then
        return false -- (asteroid, asteroid)
    end
    if obj1.is_bullet == true and obj2.is_bullet == true then
        return false -- (bullet, bullet)
    end
    if obj1.is_bullet == true and obj2.is_bullet == nil then
        return false -- (bullet, player)
    end
    if obj1.is_bullet == nil and obj2.is_bullet == true then
        return false -- (player, bullet)
    end
    collision_dist = obj1.width / 2 + obj2.width / 2
    actual_dist = util.distance(obj1.x, obj1.y, obj2.x, obj2.y)
    return actual_dist <= collision_dist
end

function update_obj(obj, dt)
    obj.x = obj.x + obj.velocity_x * dt
    obj.y = obj.y + obj.velocity_y * dt
    check_bounds(obj)
end

function fragment(asteroid)
    local asteroids = {}
    if asteroid.scale > 0.25 then
        local num_asteroids = love.math.random(2, 3)
        for i = 1, num_asteroids do
            local new_asteroid = {}
            new_asteroid.x = asteroid.x
            new_asteroid.y = asteroid.y
            new_asteroid.image = love.graphics.newImage("resources/asteroid.png")
            new_asteroid.rotation = math.random(360)
            new_asteroid.rotate_speed = math.random() * 100 - 50
            new_asteroid.velocity_x = love.math.random() * 70 + asteroid.velocity_x
            new_asteroid.velocity_y = love.math.random() * 70 + asteroid.velocity_y
            new_asteroid.dead = false
            new_asteroid.scale = asteroid.scale * 0.5
            new_asteroid.width = asteroid.image:getWidth() * new_asteroid.scale
            new_asteroid.height = asteroid.image:getHeight() * new_asteroid.scale
            new_asteroid.is_bullet = false
            table.insert(asteroids, new_asteroid)
        end
    end
    return asteroids
end

function load_asteroids(num_asteroids, player_x, player_y)
    -- load asteroid info, keep away from the player
    local asteroids = {}
    for i = 1, num_asteroids do
        local asteroid = { x = player_x, y = player_y }
        while util.distance(asteroid.x, asteroid.y, player_x, player_y) < 100 do
            asteroid.x = math.random(800)
            asteroid.y = math.random(600)
        end
        asteroid.image = love.graphics.newImage("resources/asteroid.png")
        asteroid.rotation = math.random(360)
        asteroid.rotate_speed = math.random() * 100 - 50
        asteroid.width = asteroid.image:getWidth()
        asteroid.height = asteroid.image:getHeight()
        asteroid.velocity_x = love.math.random() * 40
        asteroid.velocity_y = love.math.random() * 40
        asteroid.dead = false
        asteroid.scale = 1
        asteroid.is_bullet = false
        table.insert(asteroids, asteroid)
    end
    return asteroids
end

function load_player()
    return Player:new()
end

function load_player_lives(num_icons)
    local sprite_batch = love.graphics.newSpriteBatch(player_image, 3)
    for i = 1, num_icons do
        sprite_batch:add(785-(i-1)*30, 15, 0, 0.5, 0.5, player_image:getWidth() / 2,
                         player_image:getHeight() / 2, 0, 0)
    end
    return sprite_batch
end

function load_engine_flame()
    return Engine:new()
end

function load_bullet()
    local bullet = {}
    bullet.image = love.graphics.newImage("resources/bullet.png")
    bullet.width = bullet.image:getWidth()
    bullet.height = bullet.image:getHeight()
    angle_radians = math.rad(player_ship.rotation)
    ship_radius = player_ship.width / 2
    bullet.x = player_ship.x + math.cos(angle_radians) * ship_radius
    bullet.y = player_ship.y + math.sin(angle_radians) * ship_radius
    bullet.velocity_x = player_ship.velocity_x + math.cos(angle_radians) * 700
    bullet.velocity_y = player_ship.velocity_y + math.sin(angle_radians) * 700
    bullet.dead = false
    bullet.survival = 0
    bullet.is_bullet = true
    return bullet
end

function update_asteroid(asteroid, dt)
    update_obj(asteroid, dt)
    asteroid.rotation = asteroid.rotation + asteroid.rotate_speed * dt
end

function update_bullet(bullet, dt)
    update_obj(bullet, dt)
end

function update_player(dt)
    local player = player_ship
    update_obj(player, dt)

    if love.keyboard.isDown("left") then
        player.rotation = player.rotation - player.rotate_speed * dt
    end
    if love.keyboard.isDown("right") then
        player.rotation = player.rotation + player.rotate_speed * dt
    end

    if love.keyboard.isDown("up") then
        angle_radians = math.rad(player.rotation)
        force_x = math.cos(angle_radians) * player.thrust * dt
        force_y = math.sin(angle_radians) * player.thrust * dt
        player.velocity_x = player.velocity_x + force_x
        player.velocity_y = player.velocity_y + force_y
        -- update engine sprite
        engine_sprite.rotation = player.rotation
    engine_sprite.x = player.x
    engine_sprite.y = player.y
    engine_sprite.visible = true
    else
        engine_sprite.visible = false
    end
end

function reset_level(num_lives)
    num_lives = num_lives or 2
    player_ship = load_player()
    player_lives = load_player_lives(num_lives)
    asteroids = load_asteroids(total_asteroids, player_ship.x, player_ship.y)
    bullets = {}
end
-----------------------love function-----------------

function love.load()
    main_font = love.graphics.newFont(15)
    game_over_font = love.graphics.newFont(48)
    love.graphics.setFont(main_font)
    engine_sprite = load_engine_flame()
    bullet_sound = love.audio.newSource("resources/bullet.wav", "static")
    player_image = love.graphics.newImage("resources/player.png")
    -- Initialize the game
    reset_level(2)
end

function love.draw()
    -- draw label
    local level_label_width = main_font:getWidth(level_label)
    love.graphics.print(score_label .. score, 10, 25)
    love.graphics.printf(level_label, 400, 25, level_label_width,
                         "left", 0, 1, 1, level_label_width / 2)
    if player_ship == nil and player_lives:getCount() == 0 then
        local game_label_width = game_over_font:getWidth(game_over_label)
        love.graphics.setFont(game_over_font)
        love.graphics.printf(game_over_label, 400, 300, game_label_width,
                             "left", 0, 1, 1, game_label_width / 2)
        love.graphics.setFont(main_font)
    end

    -- draw player ship and engine flame
    if player_ship then
        love.graphics.draw(player_ship.image, player_ship.x, player_ship.y, math.rad(player_ship.rotation),
                           1, 1, player_ship.width / 2, player_ship.height / 2)
        if engine_sprite.visible then
            love.graphics.draw(engine_sprite.image, engine_sprite.x, engine_sprite.y,
                               math.rad(engine_sprite.rotation), 1, 1, engine_sprite.width * 1.5,
                               engine_sprite.height / 2)
        end
    end

    -- draw asteroids
    for _, v in ipairs(asteroids) do
        love.graphics.draw(v.image, v.x, v.y, math.rad(v.rotation),
                           v.scale, v.scale, v.width / 2, v.height / 2)
    end

    -- draw player lives in sprite batch
    love.graphics.draw(player_lives)

    -- draw bullets
    for _, v in ipairs(bullets) do
        love.graphics.draw(v.image, v.x, v.y, 0, 1, 1, v.width / 2, v.height / 2)
    end

    -- draw FPS
    love.graphics.setFont(game_over_font)
    love.graphics.print(tostring(love.timer.getFPS()), 10, 550)
    love.graphics.setFont(main_font)
end

function love.update(dt)
    if player_ship then
        update_player(dt)
    end
    for _, v in ipairs(asteroids) do
        update_asteroid(v, dt)
    end
    for _, v in ipairs(bullets) do
        update_bullet(v, dt)
    end

    objects = {}
    if player_ship then
        table.insert(objects, player_ship)
    end
    for _, v in ipairs(asteroids) do
        table.insert(objects, v)
    end
    for _, v in ipairs(bullets) do
        table.insert(objects, v)
    end
    -- collision detection
    for i = 1, #objects do
        for j = i+1, #objects do
            obj_1 = objects[i]
            obj_2 = objects[j]
            if not obj_1.dead and not obj_2.dead then
                if collide(obj_1, obj_2) then
                    obj_1.dead = true
                    obj_2.dead = true
                end
            end
        end
    end

    -- remove dead objects
    if player_ship and player_ship.dead then
        player_ship = nil
    end
    local temp_asteroids = {}
    local temp_bullets = {}
    for _, v in ipairs(objects) do
        if v.is_bullet == true then
            v.survival = v.survival + dt
            if v.survival < 0.5 and not v.dead then
                table.insert(temp_bullets, v)
            end
        end
        if v.is_bullet == false then
            if not v.dead then
                table.insert(temp_asteroids, v)
            else
                score = score + 1
                small_asteroids = fragment(v)
                for _, v2 in ipairs(small_asteroids) do
                    table.insert(temp_asteroids, v2)
                end
            end
        end
    end
    asteroids = temp_asteroids
    bullets = temp_bullets

    -- victory judgement
    local num_lives = player_lives:getCount()
    if player_ship == nil then
        -- reset level or game over
        if num_lives > 0 then
            reset_level(num_lives - 1)
        else
            return
        end
    elseif not player_ship.dead and #asteroids == 0 then
        total_asteroids = total_asteroids + 1
        score = score + 10
        reset_level(player_lives:getCount())
    end
end

function love.keypressed(key)
    if key == " " and player_ship and not player_ship.dead then
        local bullet = load_bullet()
	    table.insert(bullets, bullet)
	    love.audio.play(bullet_sound)
    end
end
