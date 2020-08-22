splash = "assets/misc/splash.bmp"
borderLeft = "assets/misc/borderLeft.png"
borderRight = "assets/misc/borderRight.png"
isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"

-- Splash screen
if not isMobile and love.graphics and love.graphics.isActive() then
  local s = love.graphics.newImage(splash)
  love.graphics.clear(0, 0, 0, 1)
  love.graphics.draw(s, (love.graphics.getWidth()/2)-(s:getWidth()/2), (love.graphics.getHeight()/2)-(s:getHeight()/2))
  love.graphics.present()
  s:release()
end

keyboardCheck = {}
gamepadCheck = {}

lastPressed = {type=nil, input=nil, name=nil}
lastTouch = {x=nil, y=nil, id=nil, pressure=nil, dx=nil, dy=nil}
lastTextInput = nil

-- Initializes the whole game to its base state.
function initEngine()
  keyboardCheck = {}
  gamepadCheck = {}
  love.graphics.setFont(mmFont)
  inputHandler.init()
  control.init()
  globals = {}
  view.init(256, 224, 1)
  cscreen.init(view.w*view.scale, view.h*view.scale, borderLeft, borderRight)
  
  megautils.runFile("core/commands.lua")
  
  -- Game globals.
  globals.checkpoint = "start"
  globals.lifeSegments = 7
  globals.startingLives = 2
  globals.playerCount = 1
  globals.disclaimerState = "assets/states/menus/disclaimer.state.lua"
  globals.bossIntroState = "assets/states/menus/bossintro.state.lua"
  globals.weaponGetState = "assets/states/menus/weaponget.state.lua"
  globals.rebindState = "assets/states/menus/rebind.state.lua"
  globals.titleState = "assets/states/menus/title.state.lua"
  globals.menuState = "assets/states/menus/menu.state.tmx"
  globals.stageSelectState = "assets/states/menus/stageSelect.state.tmx"
  
  megautils.difficultyChangeFuncs.startingLives = {func=function(d)
      globals.startingLives = (d == "easy") and 3 or 2
    end, autoClean=false}
  
  -- `globals.defeats` tells who you've defeated. Fill this in appropriatly. Your `bossEntity` should be configured to fill this in.
  globals.defeats = {}
  globals.defeats.stickMan = false
  
  for k, v in pairs(megautils.cleanFuncs) do
    if type(v) == "function" then
      v()
    else
      v.func()
    end
  end
  
  megautils.unloadAllResources()
  
  for k, v in pairs(megautils.initEngineFuncs) do
    if type(v) == "function" then
      v()
    else
      v.func()
    end
  end
  
  megautils.setDifficulty("normal")
  
  megautils.runFile("init.lua")
end

function love.load()
  love.keyboard.setKeyRepeat(true)
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Engine globals.
  consoleFont = love.graphics.getFont() -- Needs to be preserved
  altEnterOnce = false
  scaleOnce = false
  deadZone = 0.8
  defaultFPS = 60
  defaultFramerate = 1/defaultFPS
  mapCacheSize = 2
  extraSkinCacheSize = 1 -- Increase this if you're using a lot of skins at once outside the boundaries of `maxPlayerCount`
  clampSkinShootOffsets = true
  useConsole = love.keyboard
  mmFont = love.graphics.newFont("assets/misc/mm.ttf", 8)
  
  maxPlayerCount = 4
  maxLives = 10
  maxETanks = 10
  maxWTanks = 10
  
  require("requires")
  
  console.init()
  initEngine()
  
  local data = save.load("main.sav") or {}
  if data.fullscreen then
    megautils.setFullscreen(true)
  end
  if data.scale then
    megautils.setScale(data.scale)
  end
  
  megautils.gotoState(globals.disclaimerState)
  console.parse("exec autoexec")
end

function love.resize(w, h)
  cscreen.update(w, h)
  if console.state == 0 and console.y == -console.h then
    console.y = -math.huge
    console.update()
  end
end

function love.joystickadded(j)
  control.loadBinds()
end

function love.joystickremoved(j)
  control.loadBinds()
end

function love.keypressed(k, s, r)
  if control.demo and not control.pressAnyway then
    control.anyPressedDuringRec = true
    return
  end
  
  -- keypressed event must be hijacked for console to work
	if useConsole and console.state == 1 then
		if (k == "backspace") then
			console.backspace()
		end
		if (k == "return") then
			console.send()
		end
		if (k == "up" or k == "down") then
			console.cycle(k)
		end
		if (k == "tab" and #console.input > 0 and #console.getCompletion(console.input) > 0) then
			console.complete()
		end
    return
	end
  
  if not keyboardCheck[k] then
    lastPressed.type = "keyboard"
    lastPressed.input = k
  end
  keyboardCheck[k] = 5
  
  control.anyPressed = true
  
  if control.recordInput then
    if not control.keyPressedRec then
      control.keyPressedRec = {}
    end
    control.keyPressedRec[#control.keyPressedRec+1] = {k, s, r}
  end
end

function love.gamepadpressed(j, b)
  if control.demo and not control.pressAnyway then
    control.anyPressedDuringRec = true
    return
  end
  if useConsole and console.state == 1 then return end
  
  if not gamepadCheck[b] then
    lastPressed.type = "gamepad"
    lastPressed.input = b
    lastPressed.name = j:getName()
  end
  gamepadCheck[b] = 5
  
  control.anyPressed = true
  
  if control.recordInput then
    if not control.gamepadPressedRec then
      control.gamepadPressedRec = {}
    end
    control.gamepadPressedRec[#control.gamepadPressedRec+1] = {k, s, r}
  end
end

function love.gamepadaxis(j, b, v)
  if control.demo and not control.pressAnyway then return end
  if useConsole and console.state == 1 then return end
  
  if not math.between(v, -deadZone, deadZone) then
    if not gamepadCheck[b] then
      if (b == "leftx" or b == "lefty" or b == "rightx" or b == "righty") then
        globals.axisTmp = {}
        if b == "leftx" or b == "rightx" then
          globals.axisTmp.x = {"axis", b .. (v > 0 and "+" or "-"), v, j:getName()}
        elseif b == "lefty" or b == "righty" then
          globals.axisTmp.y = {"axis", b .. (v > 0 and "+" or "-"), v, j:getName()}
        end
      else
        lastPressed.type = "axis"
        lastPressed.input = b .. (v > 0 and "+" or "-")
        lastPressed.name = j:getName()
      end
    end
    gamepadCheck[b] = 10
  end
  
  if control.recordInput then
    if not control.gamepadAxisRec then
      control.gamepadAxisRec = {}
    end
    control.gamepadAxisRec[#control.gamepadAxisRec+1] = {k, s, r}
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  if control.demo and not control.pressAnyway then
    control.anyPressedDuringRec = true
    return
  end
  if useConsole and console.state == 1 then return end
  
  lastTouch.x = x
  lastTouc.y = y
  lastTouch.id = id
  lastTouch.pressure = pressure
  lastTouch.dx = dx
  lastTouch.dy = dy
  
  if control.recordInput then
    if not control.touchPressedRec then
      control.touchPressedRec = {}
    end
    control.touchPressedRec[#control.touchPressedRec+1] = {k, s, r}
  end
end

function love.textinput(k)
  if control and control.demo and not control.pressAnyway then return end
  if useConsole and console then console.doInput(k) end
  
  lastTextInput = k
  
  if control and control.recordInput then
    if not control.textInputRec then
      control.textInputRec = {}
    end
    control.textInputRec[#control.textInputRec+1] = k
  end
end

function love.update(dt)
  if love.keyboard and not (useConsole and console.state == 1) then
    if (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt")) and love.keyboard.isDown("return") then
      if not altEnterOnce then
        megautils.setFullscreen(not megautils.getFullscreen())
        local data = save.load("main.sav") or {}
        data.fullscreen = megautils.getFullscreen()
        save.save("main.sav", data)
      end
      altEnterOnce = 10
    end
    
    if altEnterOnce then
      altEnterOnce = altEnterOnce - 1
      if altEnterOnce == 0 then
        altEnterOnce = false
      end
      return
    end
    
    for i=1, 9 do
      local k = tostring(i)
      if love.keyboard.isDown(k) or love.keyboard.isDown("kp" .. k) then
        if view.w * i ~= love.graphics.getWidth() or
          view.h * i ~= love.graphics.getHeight() then
          if not scaleOnce then
            megautils.setScale(i)
            local data = save.load("main.sav") or {}
            data.scale = megautils.getScale()
            save.save("main.sav", data)
          end
          scaleOnce = 10
        end
      end
    end
    
    if scaleOnce then
      scaleOnce = scaleOnce - 1
      if scaleOnce == 0 then
        scaleOnce = false
      end
      return
    end
  end
  
  local doAgain = true
  
  while doAgain do
    states.switched = false
    control.update()
    if useConsole then console.update(dt) end
    states.update(dt)
    states.checkQueue()
    control.flush()
    doAgain = states.switched
  end
  
  if love.joystick then
    if globals.axisTmp then
      if globals.axisTmp.x and (not globals.axisTmp.y or
        math.abs(globals.axisTmp.x[3]) > math.abs(globals.axisTmp.y[3])) then
        lastPressed = {globals.axisTmp.x[1], globals.axisTmp.x[2], globals.axisTmp.x[4]}
      elseif globals.axisTmp.y then
        lastPressed = {globals.axisTmp.y[1], globals.axisTmp.y[2], globals.axisTmp.y[4]}
      end
      globals.axisTmp = nil
    end
    for k, v in pairs(gamepadCheck) do
      gamepadCheck[k] = gamepadCheck[k] - 1
      if gamepadCheck[k] < 0 then
        gamepadCheck[k] = nil
      end
    end
  end
  if love.keyboard then
    for k, v in pairs(keyboardCheck) do
      keyboardCheck[k] = keyboardCheck[k] - 1
      if keyboardCheck[k] < 0 then
        keyboardCheck[k] = nil
      end
    end
  end
end

function love.draw()
  love.graphics.push()
  view.draw()
  love.graphics.pop()
  if useConsole then console.draw() end
end

function love.quit()
  if mmMusic and mmMusic.thread:isRunning() then
    mmMusic.stop()
    mmMusic.thread:wait()
  end
end

-- Love2D doesn't fire the resize event for several functions, so here's some hacks.
local lf = love.window.setFullscreen
local lsm = love.window.setMode
local lum = love.window.updateMode

function love.window.setFullscreen(s)
  lf(s)
  love.resize(love.graphics.getDimensions())
end

function love.window.setMode(w, h, f)
  lsm(w, h, f)
  love.resize(love.graphics.getDimensions())
end

function love.window.updateMode(w, h, f)
  lum(w, h, f)
  love.resize(love.graphics.getDimensions())
end

function love.run()
  local bu = love.timer.getTime()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if love.timer then love.timer.step() end
  return function()
      if love.event then
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
          if name == "quit" then
            if not love.quit or not love.quit() then
              return a or 0
            end
          end
          love.handlers[name](a,b,c,d,e,f)
        end
      end
      if love.update then love.update(love.timer and love.timer.step()) end
      if love.graphics and love.graphics.isActive() then
        love.graphics.origin()
        love.graphics.clear(love.graphics.getBackgroundColor())
        if love.draw then love.draw() end
        love.graphics.present()
      end
      if love.timer then
        local delta, fps = love.timer.getTime() - bu, 1/megautils.getFPS()
        if delta < fps then love.timer.sleep(fps - delta) end
        bu = love.timer.getTime()
      end
      
      megautils.checkQueue()
      states.checkQueue()
      mmMusic.checkQueue()
      console.doWait()
      control.anyPressed = false
      control.anyPressedDuringRec = false
      cscreen.updateFade()
      
      lastPressed.type = nil
      lastPressed.input = nil
      lastPressed.name = nil
      lastTouch.x = nil
      lastTouch.y = nil
      lastTouch.id = nil
      lastTouch.pressure = nil
      lastTouch.dx = nil
      lastTouch.dy = nil
      lastTextInput = nil
    end
end

-- Save state to memory
function ser()
  local data = {
      cscreen = cscreen.ser(),
      view = view.ser(),
      entitySystem = entitySystem.ser(),
      loader = loader.ser(),
      music = mmMusic.ser(),
      state = states.ser(),
      control = control.ser(),
      megautils = megautils.ser(),
      collision = collision.ser(),
      banner = banner.ser(),
      banIDs = table.clone(pickupEntity.banIDs),
      weapon = weapon.ser(),
      camera = camera.main and camera.main.id,
      fade = fade.main and fade.main.id,
      megaMan = megaMan.ser(),
      lastPressed = table.clone(lastPressed),
      lastTextInput = table.clone(lastTextInput),
      lastTouch = table.clone(lastTouch),
      keyboardCheck = table.clone(keyboardCheck),
      gamepadCheck = table.clone(gamepadCheck),
      globals = table.clone(globals),
      convars = convar.getAllValues(),
      seed = love.math.getRandomSeed(),
      console = console.ser(),
      basicEntity = basicEntity.id,
      mapEntity = mapEntity.ser()
    }
  return binser.serialize(data)
end

-- Load state
function deser(t)
  
end