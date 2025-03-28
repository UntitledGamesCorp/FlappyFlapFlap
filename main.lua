local bird = { x = 100, y = 200, vy = 0, r = 15 }
local gravity = 0.6
local flapStrength = -10
local pipes = {}
local pipeWidth = 40
local pipeGap = 120
local spawnInterval = 90
local frameCount = 0
local score = 0
local hillColor = { 34, 139, 34 }

local gameState = "menu"

function setup()
    createWindow(400, 400)
    textSize(24)
    textAlign(CENTER, CENTER)
end

function draw()
    if gameState == "menu" then
        drawMenu()
    else
        drawGame()
    end
end

function drawMenu()
    -- Draw background
    background(135, 206, 235)
    drawHills()

    -- Draw menu text
    fill('white')
    text("FlappyFlapFlap", width / 2, height / 3)

    -- Draw play button
    rectMode(CENTER)
    fill('green')
    rect(width / 2, height / 2 + 40, 100, 40)

    -- Draw play text
    fill('white')
    text("Play", width / 2, height / 2 + 50)
end

function drawGame()
    background(135, 206, 235)
    drawHills()
    drawBird()

    -- Update bird's position
    bird.vy = bird.vy + gravity
    bird.y = bird.y + bird.vy
    if bird.y > height - bird.r then
        bird.y = height - bird.r
        bird.vy = 0
    end

    -- Pipe logic
    if frameCount % spawnInterval == 0 then
        spawnPipe()
    end

    stroke(0) -- Add a stroke to help debug shapes
    for i = #pipes, 1, -1 do
        local pipe = pipes[i]
        pipe.x = pipe.x - 3

        rectMode(CORNER)
        fill('green')
        rect(pipe.x, 0, pipeWidth, pipe.top)
        rect(pipe.x, pipe.top + pipeGap, pipeWidth, height - pipe.top - pipeGap)

        if pipe.x + pipeWidth < 0 then
            table.remove(pipes, i)
        elseif pipe.x + pipeWidth < bird.x and not pipe.scored then
            score = score + 1
            pipe.scored = true
        end

        if checkCollision(pipe) then
            resetGame()
        end
    end

    -- Display score
    fill('white')
    text("Score: " .. score, width / 2, 30)
    frameCount = frameCount + 1
end

function mousePressed()
    if gameState == "menu" then
        -- Check if the play button is clicked
        if mouseX > width / 2 - 50 and mouseX < width / 2 + 50 and mouseY > height / 2 + 20 and mouseY < height / 2 + 60 then
            gameState = "game"
        end
    else
        bird.vy = flapStrength
    end
end

function spawnPipe()
    local top = math.random(50, height - pipeGap - 50)
    table.insert(pipes, { x = width, top = top, scored = false })
end

function checkCollision(pipe)
    return bird.x + bird.r > pipe.x and bird.x - bird.r < pipe.x + pipeWidth and
           (bird.y - bird.r < pipe.top or bird.y + bird.r > pipe.top + pipeGap)
end

function resetGame()
    bird.y = 200
    bird.vy = 0
    pipes = {}
    score = 0
    frameCount = 0
    gameState = "menu"
end

function drawHills()
    fill(hillColor[1], hillColor[2], hillColor[3])
    arc(100, height, 200, 100, 3.14, 6.28)
    arc(300, height, 200, 120, 3.14, 6.28)
end

function drawBird()
    fill('yellow')
    noStroke()
    circle(bird.x, bird.y, bird.r * 2)
    -- Draw bird's eye
    fill('black')
    ellipse(bird.x + 6, bird.y - 6, 5, 5)
    -- Draw bird's beak
    fill('orange')
    triangle(bird.x + 10, bird.y, bird.x + 20, bird.y - 3, bird.x + 20, bird.y + 3)
end