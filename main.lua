-- Engine globals.
splash = "assets/misc/splash.bmp"
borderLeft = "assets/misc/borderLeft.png"
borderRight = "assets/misc/borderRight.png"
isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
deadZone = 0.8
defaultFPS = 60
extraSkinCacheSize = 1 -- Increase this if you're using a lot of skins at once outside the boundaries of `maxPlayerCount`
clampSkinShootOffsets = true
useConsole = love.keyboard
mmFont = love.graphics.newFont("assets/misc/mm.ttf", 8)
maxPlayerCount = 4
maxLives = 10
maxETanks = 10
maxWTanks = 10

-- Splash screen
if not isMobile and love.graphics then
  local s = love.graphics.newImage(splash)
  love.graphics.clear(0, 0, 0, 1)
  love.graphics.draw(s, (love.graphics.getWidth()/2)-(s:getWidth()/2), (love.graphics.getHeight()/2)-(s:getHeight()/2))
  love.graphics.present()
  s:release()
end

serQueue = nil
deserQueue = nil

keyboardCheck = {}
gamepadCheck = {}
doCheckDelay = false

lastPressed = {type=nil, input=nil, name=nil}
lastTouch = {x=nil, y=nil, id=nil, pressure=nil, dx=nil, dy=nil}
lastTextInput = nil

altEnterOnce = false
scaleOnce = {false, false, false, false, false, false, false, false, false}
contextOnce = false


-- Initializes the whole game to its base state.
function initEngine()
  keyboardCheck = {}
  gamepadCheck = {}
  doCheckDelay = false
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
  globals.defeats = {}
  globals.disclaimerState = "assets/states/menus/disclaimer.state.lua"
  globals.bossIntroState = "assets/states/menus/bossintro.state.lua"
  globals.weaponGetState = "assets/states/menus/weaponget.state.lua"
  globals.rebindState = "assets/states/menus/rebind.state.lua"
  globals.titleState = "assets/states/menus/title.state.lua"
  globals.menuState = "assets/states/menus/menu.state.tmx"
  globals.stageSelectState = "assets/states/menus/stageSelect.state.tmx"
  globals.gameOverState = "assets/states/menus/cont.state.tmx"
  
  megautils.difficultyChangeFuncs.startingLives = {func=function(d)
      globals.startingLives = (d == "easy") and 3 or 2
    end, autoClean=false}
  
  for _, v in pairs(megautils.cleanFuncs) do
    if type(v) == "function" then
      v()
    else
      v.func()
    end
  end
  
  megautils.unloadAllResources()
  
  for _, v in pairs(megautils.initEngineFuncs) do
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
  
  io = nil -- Prevents the worst case scenerio involving external context files. Be careful, a bad context file could still wipe your save directory
  require = nil
  dofile = nil
  loadfile = nil
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
  if pressingHardInputs(k) and not control.pressAnyway then return end
  if control.demo and not control.pressAnyway then
    control.anyPressedDuringRec = true
    return
  end
  
  -- keypressed event must be hijacked for console to work
	if useConsole then
    if k == "`" then
      if console.state == 0 then
        console.open()
      elseif console.state == 1 then
        console.close()
      end
      return
    elseif console.state == 1 then
      if k == "backspace" then
        console.backspace()
      end
      if k == "return" then
        console.send()
      end
      if k == "up" or k == "down" then
        console.cycle(k)
      end
      if k == "tab" and #console.input > 0 and #console.getCompletion(console.input) > 0 then
        console.complete()
      end
      return
    end
	end
  
  if not doCheckDelay or not keyboardCheck[k] then
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
  
  if not doCheckDelay or not gamepadCheck[b] then
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
    if not doCheckDelay or not gamepadCheck[b] then
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
  if pressingHardInputs(k) and not control.pressAnyway then return end
  if control.demo and not control.pressAnyway then return end
  if useConsole then console.doInput(k) end
  
  lastTextInput = k
  
  if control and control.recordInput then
    if not control.textInputRec then
      control.textInputRec = {}
    end
    control.textInputRec[#control.textInputRec+1] = k
  end
end

function love.update(dt)
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
  
  mmMusic.update()
  
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
    for k, _ in pairs(gamepadCheck) do
      gamepadCheck[k] = gamepadCheck[k] - 1
      if gamepadCheck[k] < 0 then
        gamepadCheck[k] = nil
      end
    end
  end
  if love.keyboard then
    for k, _ in pairs(keyboardCheck) do
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

function pressingHardInputs(k)
  if megautils then
    local isHardKey = false
    local checkMod = 0
    
    if k == "return" then
      isHardKey = true
      checkMod = 1
    elseif (k == "o" or k == "p" or k == "r") and megautils.isCheating() then
      isHardKey = true
      checkMod = 2
    elseif k == "ralt" or k == "lalt" then
      isHardKey = true
      checkMod = -1
    elseif (k == "rctrl" or k == "lctrl") and megautils.isCheating() then
      isHardKey = true
      checkMod = -2
    end
    
    for i=1, 9 do
      if (i == k or ("kp" .. i == k)) then
        isHardKey = true
      end
    end

    return isHardKey and love.keyboard.isDown(k) and (checkMod == 0 or (checkMod == 1 and
      (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt"))) or
      (checkMod == 2 and (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl"))) or
      (checkMod == -1 and love.keyboard.isDown("return")) or
      (checkMod == -2 and (love.keyboard.isDown("o") or love.keyboard.isDown("p") or love.keyboard.isDown("r"))))
  end
  
  return false
end

function love.run()
  local bu = love.timer.getTime()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if love.timer then love.timer.step() end
  return function()
      if love.keyboard and console and save and megautils then
        if not (useConsole and console.state == 1) then
          if not love.keyboard.isDown("return") then
            altEnterOnce = false
          elseif (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt")) and love.keyboard.isDown("return") then
            if not altEnterOnce then
              megautils.setFullscreen(not megautils.getFullscreen())
              local data = save.load("main.sav") or {}
              data.fullscreen = megautils.getFullscreen()
              save.save("main.sav", data)
            end
            altEnterOnce = true
          end
          
          for i=1, 9 do
            local k = tostring(i)
            if love.keyboard.isDown(k) or love.keyboard.isDown("kp" .. k) then
              if view.w * i ~= love.graphics.getWidth() or
                view.h * i ~= love.graphics.getHeight() then
                local last = megautils.getScale()
                megautils.setScale(i)
                if i ~= last then
                  if not scaleOnce[i] then
                    local data = save.load("main.sav") or {}
                    data.scale = megautils.getScale()
                    save.save("main.sav", data)
                  end
                  scaleOnce[i] = true
                end
              end
            else
              scaleOnce[i] = false
            end
          end
        end
        
        if not love.keyboard.isDown("o") and not love.keyboard.isDown("p") and not love.keyboard.isDown("r") then
          contextOnce = false
        elseif (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
          if love.keyboard.isDown("o") then
            if not contextOnce then
              console.parse("contextsave quickContext")
            end
            contextOnce = true
          elseif love.keyboard.isDown("p") then
            if not contextOnce then
              console.parse("contextopen quickContext")
            end
            contextOnce = true
          elseif love.keyboard.isDown("r") then
            if not contextOnce then
              console.parse("rec")
            end
            contextOnce = true
          end
        end
      end
      
      if serQueue then
        local f = serQueue
        serQueue = nil
        f(ser())
      end
      
      if deserQueue then
        local f = deserQueue
        if type(deserQueue) == "function" then
          f = deserQueue()
        end
        deserQueue = nil
        deser(f)
      end
      
      if control._openRecQ then
        local f = control._openRecQ
        control._openRecQ = nil
        control.openRec(f)
      end
      
      if control._startRecQ then
        control._startRecQ = false
        control.startRec()
      end
      
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
      serQueue = serQueue,
      deserQueue = deserQueue,
      backgroundColor = {love.graphics.getBackgroundColor()},
      cscreen = cscreen.ser(),
      view = view.ser(),
      megautils = megautils.ser(),
      state = states.ser(),
      entitySystem = entitySystem.ser(),
      section = section.ser(),
      loader = loader.ser(),
      music = mmMusic.ser(),
      control = control.ser(),
      collision = collision.ser(),
      banner = banner and banner.ser(),
      banIDs = pickupEntity.banIDs,
      weapon = weapon.ser(),
      camera = camera.main and camera.main,
      fade = fade.main and fade.main,
      megaMan = megaMan.ser(),
      lastPressed = lastPressed,
      lastTextInput = lastTextInput,
      lastTouch = lastTouch,
      keyboardCheck = keyboardCheck,
      gamepadCheck = gamepadCheck,
      doCheckDelay = doCheckDelay,
      globals = globals,
      convars = convar.getAllValues(),
      rstate = love.math.getRandomState(),
      seed = love.math.getRandomSeed(),
      console = console.ser(),
      basicEntity = basicEntity.id,
      mapEntity = mapEntity.ser()
    }
  
  return binser.serialize(data)
end

-- Load state
function deser(from, dontChangeMusic)
  love.audio.stop()
  
  local t = binser.deserialize(from)
  
  serQueue = t.serQueue
  deserQueue = t.deserQueue
  love.graphics.setBackgroundColor(unpack(t.backgroundColor))
  cscreen.deser(t.cscreen)
  view.deser(t.view)
  megautils.deser(t.megautils)
  states.deser(t.state)
  entitySystem.deser(t.entitySystem)
  section.deser(t.section)
  loader.deser(t.loader)
  if not dontChangeMusic then
    mmMusic.deser(t.music)
  end
  control.deser(t.control)
  collision.deser(t.collision)
  if t.banner then
    banner.deser(t.banner)
  end
  pickupEntity.banIDs = t.banIDs
  weapon.deser(t.weapon)
  camera.main = t.camera
  fade.main = t.fade
  megaMan.deser(t.megaMan)
  lastPressed = t.lastPressed
  lastTextInput = t.lastTextInput
  lastTouch = t.lastTouch
  keyboardCheck = t.keyboardCheck
  gamepadCheck = t.gamepadCheck
  doCheckDelay = t.doCheckDelay
  globals = t.globals
  convar.setAllValues(t.convars)
  love.math.setRandomSeed(t.seed)
  love.math.setRandomState(t.rstate)
  console.deser(t.console)
  basicEntity.id = t.basicEntity
  mapEntity.deser(t.mapEntity)
  
  collectgarbage()
  collectgarbage()
end