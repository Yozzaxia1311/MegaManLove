-- For engine globals, see `conf.lua`.
engineGlobals(true)

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
lastTouch = {x=nil, y=nil, id=nil, pressure=nil}
lastTextInput = nil

altEnterOnce = false
scaleOnce = {false, false, false, false, false, false, false, false, false}
contextOnce = false

function useDefaultBinds()
  input.unbind()
  
  local defaultInputBinds, defaultInputBindsExtra = defaultBindsTable()
  
  input.bind(defaultInputBinds.up, "up1")
  input.bind(defaultInputBinds.down, "down1")
  input.bind(defaultInputBinds.left, "left1")
  input.bind(defaultInputBinds.right, "right1")
  input.bind(defaultInputBinds.jump, "jump1")
  input.bind(defaultInputBinds.shoot, "shoot1")
  input.bind(defaultInputBinds.dash, "dash1")
  input.bind(defaultInputBinds.start, "start1")
  input.bind(defaultInputBinds.select, "select1")
  input.bind(defaultInputBinds.prev, "prev1")
  input.bind(defaultInputBinds.next, "next1")
  
  for i=2, maxPlayerCount do
    if defaultInputBindsExtra[i] then
      input.bind(defaultInputBindsExtra[i].up, "up" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].down, "down" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].left, "left" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].right, "right" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].jump, "jump" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].shoot, "shoot" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].dash, "dash" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].start, "start" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].select, "select" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].prev, "prev" .. tostring(i))
      input.bind(defaultInputBindsExtra[i].next, "next" .. tostring(i))
    end
  end
end

function loadBinds()
  useDefaultBinds()
  
  local data = save.load("main.sav")
  
  if data and data.inputBinds then
    for i = 1, maxPlayerCount do
      if data.inputBinds["up" .. tostring(i)] then input.bind(data.inputBinds["up" .. tostring(i)], "up" .. tostring(i)) end
      if data.inputBinds["down" .. tostring(i)] then input.bind(data.inputBinds["down" .. tostring(i)], "down" .. tostring(i)) end
      if data.inputBinds["left" .. tostring(i)] then input.bind(data.inputBinds["left" .. tostring(i)], "left" .. tostring(i)) end
      if data.inputBinds["right" .. tostring(i)] then input.bind(data.inputBinds["right" .. tostring(i)], "right" .. tostring(i)) end
      if data.inputBinds["jump" .. tostring(i)] then input.bind(data.inputBinds["jump" .. tostring(i)], "jump" .. tostring(i)) end
      if data.inputBinds["shoot" .. tostring(i)] then input.bind(data.inputBinds["shoot" .. tostring(i)], "shoot" .. tostring(i)) end
      if data.inputBinds["dash" .. tostring(i)] then input.bind(data.inputBinds["dash" .. tostring(i)], "dash" .. tostring(i)) end
      if data.inputBinds["start" .. tostring(i)] then input.bind(data.inputBinds["start" .. tostring(i)], "start" .. tostring(i)) end
      if data.inputBinds["select" .. tostring(i)] then input.bind(data.inputBinds["select" .. tostring(i)], "select" .. tostring(i)) end
      if data.inputBinds["prev" .. tostring(i)] then input.bind(data.inputBinds["prev" .. tostring(i)], "prev" .. tostring(i)) end
      if data.inputBinds["next" .. tostring(i)] then input.bind(data.inputBinds["next" .. tostring(i)], "next" .. tostring(i)) end
    end
  end
end

-- Initializes the whole game to its base state.
function initEngine()
  keyboardCheck = {}
  gamepadCheck = {}
  doCheckDelay = false
  love.graphics.setFont(mmFont)
  input.init()
  loadBinds()
  record.init()
  globals = {}
  view.init(gameWidth, gameHeight, 1)
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
  globals.gameOverState = "assets/states/menus/cont.state.tmx"
  
  globals.defeats = {} -- This should be filled out automatically by bossEntity
  
  globals.defeatRequirementsForWily = {
      "stickMan"
    }
  
  local wilyIntro = function()
      error("Placeholder for Wily")
      --megautils.gotoState("WILY INTRO HERE")
    end
  
  -- [RM 1] [RM 2] [RM 3]
  -- [RM 4] [Wily] [RM 5]
  -- [RM 6] [RM 7] [RM 8]
  globals.robotMasterEntities = { -- Every value in this list should either be a function, or a `.lua` file that returns an entity.
      nil, nil, nil,
      nil, wilyIntro, "entities/demo/stickman.lua",
      nil, nil, nil
    }
  
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
  
  local data = save.load("main.sav")
  if data then
    if data.fullscreen then
      megautils.setFullscreen(true)
    end
    if data.scale then
      megautils.setScale(data.scale)
    end
  else
    save.save("main.sav", {})
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
  loadBinds()
end

function love.joystickremoved(j)
  loadBinds()
end

function love.keypressed(k, s, r)
  if pressingHardInputs(k) and not record.pressAnyway then
    if record.recordInput then
      record._backupKey = k
    end
    return
  end
  if record.demo and not record.pressAnyway then
    record.anyPressedDuringRec = true
    return
  end
  
  record.anyPressed = true
  
  if record.recordInput then
    if not record.keyPressedRec then
      record.keyPressedRec = {}
    end
    record.keyPressedRec[#record.keyPressedRec+1] = {k, s, r}
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
    input.usingTouch = false
  end
  keyboardCheck[k] = 5
end

function love.gamepadpressed(j, b)
  if record.demo and not record.pressAnyway then
    record.anyPressedDuringRec = true
    return
  end
  if useConsole and console.state == 1 then return end
  
  if not doCheckDelay or not gamepadCheck[b] then
    lastPressed.type = "gamepad"
    lastPressed.input = b
    lastPressed.name = j:getName()
    input.usingTouch = false
  end
  gamepadCheck[b] = 5
  
  record.anyPressed = true
  
  if record.recordInput then
    if not record.gamepadPressedRec then
      record.gamepadPressedRec = {}
    end
    record.gamepadPressedRec[#record.gamepadPressedRec+1] = {k, s, r}
  end
end

function love.gamepadaxis(j, b, v)
  if record.demo and not record.pressAnyway then return end
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
      input.usingTouch = false
    end
    gamepadCheck[b] = 10
  end
  
  if record.recordInput then
    if not record.gamepadAxisRec then
      record.gamepadAxisRec = {}
    end
    record.gamepadAxisRec[#record.gamepadAxisRec+1] = {k, s, r}
  end
end

function love.mousepressed(x, y, button)
  lastTouch.x, lastTouch.y = cscreen.project(x, y)
  lastTouch.id = "mousetouch"
  lastTouch.pressure = 1
  input.usingTouch = true
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  if record.demo and not record.pressAnyway then
    record.anyPressedDuringRec = true
    return
  end
  if useConsole and console.state == 1 then return end
  
  lastTouch.x, lastTouch.y = cscreen.project(x, y)
  lastTouch.id = id
  lastTouch.pressure = pressure
  input.usingTouch = true
  
  if record.recordInput then
    if not record.touchPressedRec then
      record.touchPressedRec = {}
    end
    record.touchPressedRec[#record.touchPressedRec+1] = {k, s, r}
  end
end

function love.textinput(k)
  if pressingHardInputs(k) and not record.pressAnyway then return end
  if record.demo and not record.pressAnyway then return end
  if useConsole then console.doInput(k) end
  
  lastTextInput = k
  
  if record and record.recordInput then
    if not record.textInputRec then
      record.textInputRec = {}
    end
    record.textInputRec[#record.textInputRec+1] = k
  end
end

function love.update(dt)
  local doAgain = true
  
  while doAgain do
    states.switched = false
    if not record.demo then input.poll() end
    record.update()
    if useConsole then console.update(dt) end
    states.update(dt)
    megautils.checkQueue()
    states.checkQueue()
    input.flush()
    record.anyPressed = false
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
  input.draw()
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
  if s then
    love.mouse.setVisible(true)
  elseif input and input.usingTouch then
    love.mouse.setVisible(s and not input.usingTouch)
  end
end

function love.window.setMode(w, h, f)
  lsm(w, h, f)
  love.resize(love.graphics.getDimensions())
end

function love.window.updateMode(w, h, f)
  lum(w, h, f)
  love.resize(love.graphics.getDimensions())
end

local lt = love.timer
local lk = love.keyboard
local le = love.event
local lu = love.update
local lg = love.graphics
local ld = love.draw

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
    elseif k == "backspace" and record.recordInput then
      isHardKey = true
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

    return isHardKey and lk.isDown(k) and (checkMod == 0 or (checkMod == 1 and
      (lk.isDown("ralt") or lk.isDown("lalt"))) or
      (checkMod == 2 and (lk.isDown("rctrl") or lk.isDown("lctrl"))) or
      (checkMod == -1 and lk.isDown("return")) or
      (checkMod == -2 and (lk.isDown("o") or lk.isDown("p") or lk.isDown("r"))))
  end
  
  return false
end

function love.run()
  local bu = lt and lt.getTime()
  
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
  if lt then lt.step() end
  
  return function()
      if lk and console and save and megautils then
        if not (useConsole and console.state == 1) then
          if not lk.isDown("return") then
            altEnterOnce = false
          elseif (lk.isDown("ralt") or lk.isDown("lalt")) and lk.isDown("return") then
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
            if lk.isDown(k) or lk.isDown("kp" .. k) then
              if view.w * i ~= lg.getWidth() or
                view.h * i ~= lg.getHeight() then
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
        
        if not lk.isDown("o") and not lk.isDown("p") and not lk.isDown("r") then
          contextOnce = false
        elseif (lk.isDown("lctrl") or lk.isDown("rctrl")) then
          if lk.isDown("o") then
            if not contextOnce then
              console.parse("contextsave quickContext")
            end
            contextOnce = true
          elseif lk.isDown("p") then
            if not contextOnce then
              console.parse("contextopen quickContext")
            end
            contextOnce = true
          elseif lk.isDown("r") then
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
      
      if record._openRecQ then
        local f = record._openRecQ
        record._openRecQ = nil
        record.openRec(f)
      end
      
      if record._startRecQ then
        record._startRecQ = false
        record.startRec()
      end
      
      if le then
        le.pump()
        
        for name, a,b,c,d,e,f in le.poll() do
          if name == "quit" then
            if not love.quit or not love.quit() then
              return a or 0
            end
          end
          love.handlers[name](a,b,c,d,e,f)
        end
      end
      
      if lu then lu(lt and lt.step()) end
      
      if lg and lg.isActive() then
        lg.origin()
        lg.clear(lg.getBackgroundColor())
        if ld then ld() end
        lg.present()
      end
      
      if lt then
        local delta, fps = lt.getTime() - bu, 1/megautils.getFPS()
        if delta < fps then lt.sleep(fps - delta) end
        bu = lt.getTime()
      end
      
      megautils.checkQueue()
      states.checkQueue()
      mmMusic.checkQueue()
      console.doWait()
      record.anyPressed = false
      record.anyPressedDuringRec = false
      cscreen.updateFade()
      
      lastPressed.type = nil
      lastPressed.input = nil
      lastPressed.name = nil
      lastTouch.x = nil
      lastTouch.y = nil
      lastTouch.id = nil
      lastTouch.pressure = nil
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
      record = record.ser(),
      collision = collision.ser(),
      banner = banner and banner.ser(),
      banIDs = pickup.banIDs,
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
  record.deser(t.record)
  collision.deser(t.collision)
  if t.banner then
    banner.deser(t.banner)
  end
  pickup.banIDs = t.banIDs
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
  mapEntity.deser(t.mapEntity)
  
  collectgarbage()
  collectgarbage()
end
