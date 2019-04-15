function initEngine()
  showFPS = false
  showEntityCount = false
  framerate = 1/60
  
  globals = {}
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.filesystem.load("requires.lua")()
  
  if touchControls then
    touchInput.add("left", "left-down", 16, -140, 64, 64)
    touchInput.add("right", "left-down", 16+64, -140, 64, 64)
    touchInput.add("down", "left-down", 16+32, -140+64, 64, 64)
    touchInput.add("up", "left-down", 16+32, -140-64, 64, 64)
    touchInput.add("jump", "right-down", -80, -140, 64, 64)
    touchInput.add("dash", "right-down", -80-64, -140+32, 64, 64)
    touchInput.add("shoot", "right-down", -80, -140+64, 64, 64)
    touchInput.add("start", "right-up", -40, 16, 40, 40)
    touchInput.add("select", "right-up", -80, 16, 40, 40)
    touchInput.add("escape", "left-up", 0, 16, 40, 40)
    touchInput.add("prev", "right-up", -40, 60, 40, 40)
    touchInput.add("next", "right-up", -80, 60, 40, 40)
  end
  
  view.init(256, 224, 1)
  
  mmFont = love.graphics.newImageFont("assets/misc/mm.png", "$abcdefghijklmnopqrstuvwxyz"
        .. "1234567890!?<>;/ :,-.+()%'`")
  
  cscreen.init(view.w*view.scale, view.h*view.scale, true)
  
  globals.mainPlayer = nil
  globals.player = {"mega", "proto", "bass", "roll"}
  globals.allPlayers = {}
  globals.checkpoint = "start"
  globals.infiniteLives = false
  globals.lives = 2
  globals.lifeSegments = 7
  globals.eTanks = 1
  globals.wTanks = 1
  globals.maxLifeSegments = 7
  globals.maxLives = 10
  globals.maxETanks = 10
  globals.maxWTanks = 10
  globals.startingLives = 2
  
  globals.defeats = {}
  globals.defeats.stickMan = false
  
  globals.resetState = true
  globals.manageStageResources = true
  globals.keyboardCheck = {}
  globals.gamepadCheck = {}
  
  for k, v in pairs(megautils.cleanFuncs) do
    v()
  end
  loader.clear()
  megautils.load()
  megautils.resetGameObjects()
  if love.keyboard then megautils.enableConsole() end
  collectgarbage()
end

function love.load()
  love.keyboard.setKeyRepeat(true)
  consoleFont = love.graphics.getFont() -- needs to be preserved
  OSSystem = love.system.getOS()
  touchControls = OSSystem == "Android" or OSSystem == "iOS"
  altEnterOnce = false
  deadZone = 0.8
  maxPlayerCount = 4
  playerCount = 1
  useConsole = true
  local joysticks = love.joystick.getJoysticks()
  defaultInputBinds =
    #joysticks > 0 and
    {["up"]={"lefty-", "axis", joysticks[1]:getName()},
    ["down"]={"lefty+", "axis", joysticks[1]:getName()},
    ["left"]={"leftx-", "axis", joysticks[1]:getName()},
    ["right"]={"leftx+", "axis", joysticks[1]:getName()},
    ["jump"]={"a", "gamepad", joysticks[1]:getName()},
    ["shoot"]={"x", "gamepad", joysticks[1]:getName()},
    ["start"]={"start", "gamepad", joysticks[1]:getName()},
    ["select"]={"back", "gamepad", joysticks[1]:getName()},
    ["prev"]={"leftshoulder", "gamepad", joysticks[1]:getName()},
    ["next"]={"rightshoulder", "gamepad", joysticks[1]:getName()},
    ["dash"]={"b", "gamepad", joysticks[1]:getName()}}
    or
    ({["up"]={"up", "keyboard"},
    ["down"]={"down", "keyboard"},
    ["left"]={"left", "keyboard"},
    ["right"]={"right", "keyboard"},
    ["jump"]={"z", "keyboard"},
    ["shoot"]={"x", "keyboard"},
    ["start"]={"return", "keyboard"},
    ["select"]={"rshift", "keyboard"},
    ["prev"]={"a", "keyboard"},
    ["next"]={"s", "keyboard"},
    ["dash"]={"c", "keyboard"}}
    or touchControls and
    {["up"]={"up", "touch"},
    ["down"]={"down", "touch"},
    ["left"]={"left", "touch"},
    ["right"]={"right", "touch"},
    ["jump"]={"jump", "touch"},
    ["shoot"]={"shoot", "touch"},
    ["start"]={"start", "touch"},
    ["select"]={"select", "touch"},
    ["prev"]={"prev", "touch"},
    ["next"]={"next", "touch"},
    ["dash"]={"dash", "touch"}})
  defaultInputBinds2 =
    joysticks[2] and
    {["up"]={"lefty-", "axis", joysticks[2]:getName()},
    ["down"]={"lefty+", "axis", joysticks[2]:getName()},
    ["left"]={"leftx-", "axis", joysticks[2]:getName()},
    ["right"]={"leftx+", "axis", joysticks[2]:getName()},
    ["jump"]={"a", "gamepad", joysticks[2]:getName()},
    ["shoot"]={"x", "gamepad", joysticks[2]:getName()},
    ["start"]={"start", "gamepad", joysticks[2]:getName()},
    ["select"]={"back", "gamepad", joysticks[2]:getName()},
    ["prev"]={"leftshoulder", "gamepad", joysticks[2]:getName()},
    ["next"]={"rightshoulder", "gamepad", joysticks[2]:getName()},
    ["dash"]={"b", "gamepad", joysticks[2]:getName()}} or {}
  love.filesystem.load("requirelibs.lua")()
  control.init()
  console.init()
  initEngine()
  local data = save.load("main.sav", true) or {}
  if data.fullscreen then
    convar.setValue("r_fullscreen", data.fullscreen, true)
  end
  states.set("states/disclaimer.state.lua")
  console.parse("exec autoexec")
end

function love.resize(w, h)
  cscreen.update(w, h)
  resized = true
end

function love.keypressed(k, s, r)
  -- keypressed event must be hijacked for console to work
	if useConsole and (console.state == 1) then
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
  if not globals.keyboardCheck[k] then
    globals.lastKeyPressed = {k, "keyboard"}
  end
  globals.keyboardCheck[k] = 5
  control.anyPressed = true
end

touchInput = {}

function touchInput.touchPressed(b)
  globals.lastKeyPressed = {b, "touch"}
  control.anyPressed = true
end

function love.gamepadpressed(j, b)
  if not globals.gamepadCheck[b] then
    globals.lastKeyPressed = {b, "gamepad", j:getName()}
  end
  globals.gamepadCheck[b] = 5
  control.anyPressed = true
end

function love.gamepadaxis(j, b, v)
  if not math.between(v, -deadZone, deadZone) then
    if not globals.gamepadCheck[b] then
      if (b == "leftx" or b == "lefty" or b == "rightx" or b == "righty") then
        globals.axisTmp = {}
        if b == "leftx" or b == "rightx" then
          globals.axisTmp["x"] = {b .. (v > 0 and "+" or "-"), "axis", v, j:getName()}
        elseif b == "lefty" or b == "righty" then
          globals.axisTmp["y"] = {b .. (v > 0 and "+" or "-"), "axis", v, j:getName()}
        end
      else
        globals.lastKeyPressed =  {b .. (v > 0 and "+" or "-"), "axis", j:getName()}
      end
    end
    globals.gamepadCheck[b] = 10
  end
end

function love.textinput(k)
  if useConsole then console.doInput(k) end
end

function love.update(dt)
  if love.keyboard then
    if (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt")) and love.keyboard.isDown("return") then
      if not altEnterOnce then
        if convar.getNumber("r_fullscreen") == 1 then
          convar.setValue("r_fullscreen", 0, true)
        else
          convar.setValue("r_fullscreen", 1, true)
        end
        local data = save.load("main.sav") or {}
        data.fullscreen = convar.getNumber("r_fullscreen")
        save.save("main.sav", data)
      end
      altEnterOnce = 10
      return
    elseif altEnterOnce then
      altEnterOnce = altEnterOnce - 1
      if altEnterOnce == 0 then
        altEnterOnce = false
      end
      return
    end
  end
  control.update()
  if useConsole then console.update(dt) end
  states.update(dt)
  states.switched = false
  control.flush()
  if love.joystick then
    if globals.axisTmp then
      if globals.axisTmp["x"] and (not globals.axisTmp["y"] or
        math.abs(globals.axisTmp["x"][3]) > math.abs(globals.axisTmp["y"][3])) then
        globals.lastKeyPressed = {globals.axisTmp["x"][1], globals.axisTmp["x"][2], globals.axisTmp["x"][4]}
      elseif globals.axisTmp["y"] then
        globals.lastKeyPressed = {globals.axisTmp["y"][1], globals.axisTmp["y"][2], globals.axisTmp["y"][4]}
      end
      globals.axisTmp = nil
    end
    for k, v in pairs(globals.gamepadCheck) do
      globals.gamepadCheck[k] = globals.gamepadCheck[k] - 1
      if globals.gamepadCheck[k] < 0 then
        globals.gamepadCheck[k] = nil
      end
    end
  end
  if love.keyboard then
    for k, v in pairs(globals.keyboardCheck) do
      globals.keyboardCheck[k] = globals.keyboardCheck[k] - 1
      if globals.keyboardCheck[k] < 0 then
        globals.keyboardCheck[k] = nil
      end
    end
  end
end

function love.draw()
  love.graphics.push()
  states.draw()
  love.graphics.pop()
  control.drawDemo()
  if useConsole then console.draw() end
  if touchControls then
    touchInput.draw()
  end
end

function love.run()
  if love.math then
    love.math.setRandomSeed(os.time())
  end
  if love.load then love.load(arg) end
  if love.timer then love.timer.step() end
  local dt = 0
  while true do
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end
    local before_update = love.timer.getTime()
    if love.update then love.update(dt) end
    if love.graphics and love.graphics.isActive() then
      love.graphics.clear(love.graphics.getBackgroundColor())
      love.graphics.origin()
      if love.draw then love.draw() end
      love.graphics.present()
    end
    local delta = love.timer.getTime() - before_update
    if delta < framerate then love.timer.sleep(framerate - delta) end
    resized = false
  end
end
