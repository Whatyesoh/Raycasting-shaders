if arg[2] == "debug" then
    require("lldebugger").start()
  end
  
io.stdout:setvbuf("no")

function love.load()

    ditheringOn = 1
    colerShiftOn = 1

    speed = 3
    vertSpeed = 0

    wheld = 0
    sheld = 0
    aheld = 0
    dheld = 0

    theta = 0

    cameraPos = {0,20.5,0}
    cameraLook = {0,20.5,0}
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
    sphereTexture = love.graphics.newImage("earthmap.jpg")
    quadTexture = love.graphics.newImage("quad.jpg")
    rayTracer:send("sphereTexture",sphereTexture)
    rayTracer:send("quadTexture",quadTexture)
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
    if key == "space" then
        if cameraPos[2] == 20.5 then
            vertSpeed = 5
        end
    end
    if key == "1" then
        ditheringOn = (ditheringOn - 1) * -1
    end
    if key == "2" then
        colerShiftOn = (colerShiftOn - 1) * -1
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

    cameraPos[2] = cameraPos[2] + vertSpeed * dt
    if cameraPos[2] < 20.5 then
        vertSpeed = 0
        cameraPos[2] = 20.5
    else
        vertSpeed = vertSpeed - 5 * dt
    end

    if wheld == 1 then
        cameraPos[3] = cameraPos[3] + math.sin(theta) * dt * speed
        cameraPos[1] = cameraPos[1] + math.cos(theta) * dt * speed
    end
    if aheld == 1 then
        cameraPos[3] = cameraPos[3] - math.cos(theta) * dt * speed
        cameraPos[1] = cameraPos[1] + math.sin(theta) * dt * speed
    end
    if sheld == 1 then
        cameraPos[3] = cameraPos[3] - math.sin(theta) * dt * speed
        cameraPos[1] = cameraPos[1] - math.cos(theta) * dt * speed
    end
    if dheld == 1 then
        cameraPos[3] = cameraPos[3] + math.cos(theta) * dt * speed
        cameraPos[1] = cameraPos[1] - math.sin(theta) * dt * speed
    end

    cameraLook[1] = cameraPos[1] - math.cos(math.pi - theta) 
    cameraLook[2] = cameraPos[2]
    cameraLook[3] = cameraPos[3] + math.sin(math.pi - theta) 

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
    
    if colerShiftOn == 1 then
        love.graphics.setShader(colorshift)
    end
    if ditheringOn == 1 then
        love.graphics.draw(ditheredCanvas)
    else
        love.graphics.draw(rayTracedCanvas)
    end
    love.graphics.setShader()
   
end