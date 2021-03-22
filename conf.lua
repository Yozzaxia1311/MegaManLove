-- Engine globals.
function engineGlobals(whenLoveModuleIsLoaded)
  if whenLoveModuleIsLoaded then
    mmFont = love.graphics.newFont("assets/misc/mm.ttf", 8)
    isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    useConsole = love.keyboard
  else
    gameWidth = 256
    gameHeight = 224
    gameScale = 2
    splash = "assets/misc/splash.bmp"
    borderLeft = "assets/misc/borderLeft.png"
    borderRight = "assets/misc/borderRight.png"
    deadZone = 0.8
    defaultFPS = 60
    clampSkinShootOffsets = true
    maxPlayerCount = 4
    maxLives = 10
    maxETanks = 10
    maxWTanks = 10
  end
end

function defaultBindsTable()
  input.refreshGamepads()
  local joysticks = input.gamepads
  
  local defaultInputBinds = {up={{type="keyboard", input="up"}},
    down={{type="keyboard", input="down"}},
    left={{type="keyboard", input="left"}},
    right={{type="keyboard", input="right"}},
    jump={{type="keyboard", input="z"}},
    shoot={{type="keyboard", input="x"}},
    start={{type="keyboard", input="return"}},
    select={{type="keyboard", input="rshift"}},
    prev={{type="keyboard", input="a"}},
    next={{type="keyboard", input="s"}},
    dash={{type="keyboard", input="c"}}}
  
  local defaultInputBindsExtra = {}
  
  if #joysticks > 0 then
    local joyBinds = {up={{type="axis", input="lefty-", name=joysticks[1]:getName()}, {type="gamepad", input="dpup", name=joysticks[1]:getName()}},
    down={{type="axis", input="lefty+", name=joysticks[1]:getName()}, {type="gamepad", input="dpdown", name=joysticks[1]:getName()}},
    left={{type="axis", input="leftx-", name=joysticks[1]:getName()}, {type="gamepad", input="dpleft", name=joysticks[1]:getName()}},
    right={{type="axis", input="leftx+", name=joysticks[1]:getName()}, {type="gamepad", input="dpright", name=joysticks[1]:getName()}},
    jump={{type="gamepad", input="a", name=joysticks[1]:getName()}},
    shoot={{type="gamepad", input="x", name=joysticks[1]:getName()}},
    start={{type="gamepad", input="start", name=joysticks[1]:getName()}},
    select={{type="gamepad", input="back", name=joysticks[1]:getName()}},
    prev={{type="gamepad", input="leftshoulder", name=joysticks[1]:getName()}},
    next={{type="gamepad", input="rightshoulder", name=joysticks[1]:getName()}},
    dash={{type="gamepad", input="b", name=joysticks[1]:getName()}}}
    for k, _ in pairs(defaultInputBinds) do
      if joyBinds[k] then
        for i = 1, #joyBinds[k] do
          defaultInputBinds[k][#defaultInputBinds[k] + 1] = joyBinds[k][i]
        end
      end
    end
    for i=2, #joysticks do
      defaultInputBindsExtra[i] = {up={{type="axis", input="lefty-", name=joysticks[i]:getName()}, {type="gamepad", input="dpup", name=joysticks[i]:getName()}},
      down={{type="axis", input="lefty+", name=joysticks[i]:getName()}, {type="gamepad", input="dpdown", name=joysticks[i]:getName()}},
      left={{type="axis", input="leftx-", name=joysticks[i]:getName()}, {type="gamepad", input="dpleft", name=joysticks[i]:getName()}},
      right={{type="axis", input="leftx+", name=joysticks[i]:getName()}, {type="gamepad", input="dpright", name=joysticks[i]:getName()}},
      jump={{type="gamepad", input="a", name=joysticks[i]:getName()}},
      shoot={{type="gamepad", input="x", name=joysticks[i]:getName()}},
      start={{type="gamepad", input="start", name=joysticks[i]:getName()}},
      select={{type="gamepad", input="back", name=joysticks[i]:getName()}},
      prev={{type="gamepad", input="leftshoulder", name=joysticks[i]:getName()}},
      next={{type="gamepad", input="rightshoulder", name=joysticks[i]:getName()}},
      dash={{type="gamepad", input="b", name=joysticks[i]:getName()}}}
    end
  end
  
  return defaultInputBinds, defaultInputBindsExtra
end

io.stdout:setvbuf("no")

function love.conf(t)
  engineGlobals(false)
  
  t.identity = "MMLOVE"                         -- The name of the save directory (string)
  t.appendidentity = false                      -- Search files in source directory before save directory (boolean)
  t.version = "11.3"                            -- The LÖVE version this game was made for (string)
  --t.console = false                             -- Attach a console (boolean, Windows only)
  --t.accelerometerjoystick = false               -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
  t.externalstorage = true                      -- True to save files (and read from the save directory) in external storage on Android (boolean) 
  --t.gammacorrect = false                        -- Enable gamma-correct rendering, when supported by the system (boolean)

  --t.audio.mic = false                           -- Request and use microphone capabilities in Android (boolean)
  --t.audio.mixwithsystem = true                  -- Keep background music playing when opening LOVE (boolean, iOS and Android only)

  t.window.title = "Mega Man Love"              -- The window title (string)
  t.window.icon = "assets/misc/mmIcon.png"     -- Filepath to an image to use as the window's icon (string)
  t.window.width = gameWidth * gameScale                        -- The window width (number)
  t.window.height = gameHeight * gameScale                       -- The window height (number)
  --t.window.borderless = false                   -- Remove all border visuals from the window (boolean)
  t.window.resizable = true                     -- Let the window be user-resizable (boolean)
  --t.window.minwidth = 1                         -- Minimum window width if the window is resizable (number)
  --t.window.minheight = 1                        -- Minimum window height if the window is resizable (number)
  --t.window.fullscreen = false                   -- Enable fullscreen (boolean)
  --t.window.fullscreentype = "desktop"           -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
  t.window.vsync = -1                           -- Vertical sync mode (number)
  --t.window.msaa = 0                             -- The number of samples to use with multi-sampled antialiasing (number)
  --t.window.display = 1                          -- Index of the monitor to show the window in (number)
  --t.window.highdpi = false                      -- Enable high-dpi mode for the window on a Retina display (boolean)
  --t.window.x = nil                              -- The x-coordinate of the window's position in the specified display (number)
  --t.window.y = nil                              -- The y-coordinate of the window's position in the specified display (number)

  t.modules.audio = true                        -- Enable the audio module (boolean)
  t.modules.data = true                         -- Enable the data module (boolean)
  t.modules.event = true                        -- Enable the event module (boolean)
  t.modules.font = true                         -- Enable the font module (boolean)
  t.modules.graphics = true                     -- Enable the graphics module (boolean)
  t.modules.image = true                        -- Enable the image module (boolean)
  t.modules.joystick = true                     -- Enable the joystick module (boolean)
  t.modules.keyboard = true                     -- Enable the keyboard module (boolean)
  t.modules.math = true                         -- Enable the math module (boolean)
  t.modules.mouse = false                        -- Enable the mouse module (boolean)
  t.modules.physics = false                     -- Enable the physics module (boolean)
  t.modules.sound = true                        -- Enable the sound module (boolean)
  t.modules.system = true                       -- Enable the system module (boolean)
  t.modules.thread = true                      -- Enable the thread module (boolean)
  t.modules.timer = true                        -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
  t.modules.touch = true                        -- Enable the touch module (boolean)
  t.modules.video = false                       -- Enable the video module (boolean)
  t.modules.window = true                       -- Enable the window module (boolean)
end
