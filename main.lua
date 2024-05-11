if arg[2] == "debug" then
    require("lldebugger").start()
  end
  
io.stdout:setvbuf("no")

function love.load()

    speed = 3

    wheld = 0
    sheld = 0
    aheld = 0
    dheld = 0

    theta = 0

    cameraPos = {0,100.5,0}
    cameraLook = {0,100.5,-1}
    aspectRatio = 16/9
    imageWidth = 400
    imageHeight = math.floor(imageWidth/aspectRatio)

    love.window.setFullscreen(true)
    love.window.setVSync(0)

    imageHeight = love.graphics.getHeight()
    imageWidth = love.graphics.getWidth()

    love.mouse.setPosition(imageWidth/2,imageHeight/2)
    love.mouse.setVisible(false)

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    screen = love.graphics.newCanvas(imageWidth,imageHeight)
    rayTracedCanvas = love.graphics.newCanvas(imageWidth,imageHeight)
    ditheredCanvas = love.graphics.newCanvas(imageWidth,imageHeight)

    rayTracer = love.graphics.newShader("rayTracer.frag")
    dithering = love.graphics.newShader("dithering.frag")
    colorshift = love.graphics.newShader("colorshift.frag")

    rayTracer:send("width",imageWidth)
    rayTracer:send("height",imageHeight)
    testTexture = love.graphics.newImage("testTexture.png")
    rayTracer:send("sphereTexture",testTexture)
end

function love.keypressed(key) 
    if key == "w" then
        wheld = 1
    end
    if key == "a" then
        aheld = 1
    end
    if key == "s" then
        sheld = 1
    end
    if key == "d" then
        dheld = 1
    end
end
function love.keyreleased(key)
    if key == "w" then
        wheld = 0
    end
    if key == "a" then
        aheld = 0
    end
    if key == "s" then
        sheld = 0
    end
    if key == "d" then
        dheld = 0
    end
end

function love.mousemoved(x,y,dx,dy)
    theta = theta + dx * .005
    if (love.mouse.getX() >= .7 * imageWidth or love.mouse.getX() <= .3 * imageWidth) then
        love.mouse.setPosition(imageWidth/2,imageHeight/2)
    end
end

function love.update(dt)

    

    if wheld == 1 then
        cameraPos[3] = cameraPos[3] + math.sin(theta) * dt * speed
        cameraPos[1] = cameraPos[1] + math.cos(theta) * dt * speed
        --cameraLook[3] = cameraPos[3] - 01
    end
    if aheld == 1 then
        cameraPos[3] = cameraPos[3] - math.cos(theta) * dt * speed
        cameraPos[1] = cameraPos[1] + math.sin(theta) * dt * speed
        --cameraLook[1] = cameraPos[1]
    end
    if sheld == 1 then
        cameraPos[3] = cameraPos[3] - math.sin(theta) * dt * speed
        cameraPos[1] = cameraPos[1] - math.cos(theta) * dt * speed
        --cameraLook[3] = cameraPos[3] - 01
    end
    if dheld == 1 then
        cameraPos[3] = cameraPos[3] + math.cos(theta) * dt * speed
        cameraPos[1] = cameraPos[1] - math.sin(theta) * dt * speed
        --cameraLook[1] = cameraPos[1]
    end
    cameraPos[2] = math.sqrt(math.pow(100,2) - math.pow(cameraPos[1],2) - math.pow(cameraPos[3],2)) + .5
    cameraLook[1] = cameraPos[1] - math.sin(math.pi * (cameraPos[1]+100)/200) * math.cos(math.pi - theta)
    cameraLook[2] = cameraPos[2] + math.sin(math.pi * (cameraPos[2]+100)/200) * math.cos(math.pi - theta)
    cameraLook[3] = cameraPos[3] + math.sin(math.pi * (cameraPos[3]+100)/200) * math.sin(math.pi - theta)


    rayTracer:send("lookFrom",cameraPos)
    rayTracer:send("lookAt",cameraLook)

    love.graphics.setShader(rayTracer)
    love.graphics.setCanvas(rayTracedCanvas)

    love.graphics.draw(screen)

    love.graphics.setShader(dithering)
    love.graphics.setCanvas(ditheredCanvas)

    love.graphics.draw(rayTracedCanvas)

    love.graphics.setShader()
    love.graphics.setCanvas()

    
end

function love.draw()
    
    love.graphics.setShader(colorshift)
    love.graphics.draw(ditheredCanvas)
    love.graphics.setShader()
   
end