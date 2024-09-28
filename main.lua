-- Window setup
function love.load()
	love.window.setMode(800, 600)
	love.window.setTitle("Simple 2D Platformer")

	-- Game state variables
	gameOver = false

	-- Define player attributes
	player = {
		x = 100,
		y = 450,
		width = 50,
		height = 50,
		speed = 200,
		gravity = 1500,
		jumpHeight = -750,
		velocityY = 0,
		onGround = false,
		doubleJumpAvailable = false,
	}

	-- Define vertical obstacles
	obstacles = {
		{ x = 800, height = 100, width = 50 },
		{ x = 1200, height = 150, width = 50 },
		{ x = 1600, height = 75, width = 50 },
	}

	-- Environment speed
	environmentSpeed = 200

	-- Initialize counter
	counter = 0
end

-- Handling player movement and jumping logic
function love.update(dt)
	if not gameOver then
		-- Move obstacles
		for _, obstacle in ipairs(obstacles) do
			obstacle.x = obstacle.x - environmentSpeed * dt
			if obstacle.x + obstacle.width < 0 then
				obstacle.x = 800 + math.random(100, 300)
				obstacle.height = math.random(100, 200)
				counter = counter + 1 -- Increment counter when obstacle is reset
			end
		end

		-- Apply gravity to the player
		player.velocityY = player.velocityY + player.gravity * dt
		player.y = player.y + player.velocityY * dt

		-- Ensure player doesn't fall through the floor
		if player.y + player.height >= 550 then
			player.y = 550 - player.height
			player.velocityY = 0
			player.onGround = true
			player.doubleJumpAvailable = true
		else
			player.onGround = false
		end

		-- Check for landing on obstacles
		for _, obstacle in ipairs(obstacles) do
			if checkTopCollision(player, obstacle) then
				player.y = 550 - obstacle.height - player.height
				player.velocityY = 0
				player.onGround = true
				player.doubleJumpAvailable = true
			elseif checkCollision(player, obstacle) then
				gameOver = true
			end
		end
	else
		-- Restart game if "R" is pressed during game over
		if love.keyboard.isDown("r") then
			resetGame()
		end
	end
end

-- Handle jump input
function love.keypressed(key)
	if key == "space" then
		if player.onGround then
			player.velocityY = player.jumpHeight
			player.onGround = false
		elseif player.doubleJumpAvailable then
			player.velocityY = player.jumpHeight
			player.doubleJumpAvailable = false
		end
	end
end

-- Draw the player, obstacles, and game over screen if applicable
function love.draw()
	-- Draw player
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

	-- Draw obstacles
	love.graphics.setColor(0, 1, 0)
	for _, obstacle in ipairs(obstacles) do
		love.graphics.rectangle("fill", obstacle.x, 550 - obstacle.height, obstacle.width, obstacle.height)
	end

	-- Draw the ground
	love.graphics.setColor(0.5, 0.25, 0)
	love.graphics.rectangle("fill", 0, 550, 800, 50)

	-- Draw the counter
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Score: " .. counter, 10, 10)

	-- Game over message
	if gameOver then
		love.graphics.setColor(1, 0, 0)
		love.graphics.print("Game Over! Press 'R' to Restart", 300, 250, 0, 2, 2)
	end
end

-- Reset the game to the initial state
function resetGame()
	player.y = 450
	player.velocityY = 0
	player.onGround = false
	player.doubleJumpAvailable = false
	gameOver = false

	-- Reset obstacle positions
	obstacles = {
		{ x = 800, height = 100, width = 50 },
		{ x = 1200, height = 150, width = 50 },
		{ x = 1600, height = 75, width = 50 },
	}

	-- Reset counter
	counter = 0
end

-- Basic collision detection function for horizontal collisions
function checkCollision(a, b)
	return a.x < b.x + b.width
		and a.x + a.width > b.x
		and a.y < 550 - b.height + b.height
		and a.y + a.height > 550 - b.height
end

-- Check for top collision (landing on an obstacle)
function checkTopCollision(player, obstacle)
	return player.y + player.height <= 550 - obstacle.height + 5
		and player.y + player.height + player.velocityY * love.timer.getDelta() >= 550 - obstacle.height
		and player.x + player.width > obstacle.x
		and player.x < obstacle.x + obstacle.width
end
