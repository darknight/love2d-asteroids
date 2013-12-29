player_ship = {} -- the player
score_label = "Score: 0"
level_label = "Version 1: Static Graphics"

love.math.setRandomSeed(os.time())

function distance(point1_x, point1_y, point2_x, point2_y)
    -- get distance of two points
    point1_x = point1_x or 0
    point1_y = point1_y or 0
    point2_x = point2_x or 0
    point2_y = point2_y or 0
    return math.sqrt((point1_x - point2_x) ^ 2 + (point1_y - point2_y) ^ 2)
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
	asteroid.rotation = math.rad(love.math.random(360))
	asteroid.width = asteroid.image:getWidth()
	asteroid.height = asteroid.image:getHeight()
	table.insert(asteroids, asteroid)
    end
    return asteroids
end

function load_player()
    local player = {}
    player.image = love.graphics.newImage("resources/player.png")
    player.x = 400
    player.y = 300
    player.width = player.image:getWidth()
    player.height = player.image:getHeight()
    return player
end

function love.load()
    main_font = love.graphics.newFont(15)
    player_ship = load_player()
    asteroids = load_asteroids(3, player_ship.x, player_ship.y)
end

function love.draw()
    -- draw label
    local level_width = main_font:getWidth(level_label)
    love.graphics.setFont(main_font)
    love.graphics.print(score_label, 10, 25)
    love.graphics.printf(level_label, 400, 25, level_width, "left", 0, 1, 1, level_width / 2, 0, 0, 0)
    -- draw player ship
    love.graphics.draw(player_ship.image, player_ship.x, player_ship.y, 0, 1, 1, 
                       player_ship.width / 2, player_ship.height / 2)
    -- draw asteroids
    for _, v in ipairs(asteroids) do
	love.graphics.draw(v.image, v.x, v.y, v.rotation, 1, 1, v.width / 2, v.height / 2)
    end
end

