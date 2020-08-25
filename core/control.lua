control = {}

function control.defaultBindsTable()
  inputHandler.refreshGamepads()
  local joysticks = inputHandler.gamepads
  
  local defaultInputBinds = {up={{type="keyboard", input="up"}, {type="custom", input="up"}},
    down={{type="keyboard", input="down"}, {type="custom", input="down"}},
    left={{type="keyboard", input="left"}, {type="custom", input="left"}},
    right={{type="keyboard", input="right"}, {type="custom", input="right"}},
    jump={{type="keyboard", input="z"}, {type="custom", input="jump"}},
    shoot={{type="keyboard", input="x"}, {type="custom", input="shoot"}},
    start={{type="keyboard", input="return"}, {type="custom", input="start"}},
    select={{type="keyboard", input="rshift"}, {type="custom", input="select"}},
    prev={{type="keyboard", input="a"}, {type="custom", input="prev"}},
    next={{type="keyboard", input="s"}, {type="custom", input="next"}},
    dash={{type="keyboard", input="c"}, {type="custom", input="dash"}}}
  
  local defaultInputBindsExtra = {}
  
  if #joysticks > 0 then
    local joyBinds = {up={type="axis", input="lefty-", name=joysticks[1]:getName()},
    down={type="axis", input="lefty+", name=joysticks[1]:getName()},
    left={type="axis", input="leftx-", name=joysticks[1]:getName()},
    right={type="axis", input="leftx+", name=joysticks[1]:getName()},
    jump={type="gamepad", input="a", name=joysticks[1]:getName()},
    shoot={type="gamepad", input="x", name=joysticks[1]:getName()},
    start={type="gamepad", input="start", name=joysticks[1]:getName()},
    select={type="gamepad", input="back", name=joysticks[1]:getName()},
    prev={type="gamepad", input="leftshoulder", name=joysticks[1]:getName()},
    next={type="gamepad", input="rightshoulder", name=joysticks[1]:getName()},
    dash={type="gamepad", input="b", name=joysticks[1]:getName()}}
    for k, v in pairs(defaultInputBinds) do
      defaultInputBinds[k] = table.merge({defaultInputBinds[k], {joyBinds[k]}})
    end
    for i=2, #joysticks do
      defaultInputBindsExtra[i] = {up={type="axis", input="lefty-", name=joysticks[i]:getName()},
      down={type="axis", input="lefty+", name=joysticks[i]:getName()},
      left={type="axis", input="leftx-", name=joysticks[i]:getName()},
      right={type="axis", input="leftx+", name=joysticks[i]:getName()},
      jump={type="gamepad", input="a", name=joysticks[i]:getName()},
      shoot={type="gamepad", input="x", name=joysticks[i]:getName()},
      start={type="gamepad", input="start", name=joysticks[i]:getName()},
      select={type="gamepad", input="back", name=joysticks[i]:getName()},
      prev={type="gamepad", input="leftshoulder", name=joysticks[i]:getName()},
      next={type="gamepad", input="rightshoulder", name=joysticks[i]:getName()},
      dash={type="gamepad", input="b", name=joysticks[i]:getName()}}
    end
  end
  
  return defaultInputBinds, defaultInputBindsExtra
end

function control.ser()
  return {
      demo = control.demo,
      anyPressed = control.anyPressed,
      pressAnyway = control.pressAnyway,
      anyPressedDuringRec = control.anyPressedDuringRec,
      recPos = control.recPos,
      record = control.record,
      loadedRec = control.loadedRec,
      loadedRecPos = control.loadedRecPos,
      recordInput = control.recordInput,
      keyPressedRec = control.keyPressedRec,
      gamepadPressedRec = control.gamepadPressedRec,
      gamepadAxisRec = control.gamepadAxisRec,
      touchPressedRec = control.touchPressedRec,
      textInputRec = control.textInputRec,
      leftDown = control.leftDown,
      leftPressed = control.leftPressed,
      rightDown = control.rightDown,
      rightPressed = control.rightPressed,
      upDown = control.upDown,
      upPressed = control.upPressed,
      downDown = control.downDown,
      downPressed = control.downPressed,
      startDown = control.startDown,
      startPressed = control.startPressed,
      selectDown = control.selectDown,
      selectPressed = control.selectPressed,
      jumpDown = control.jumpDown,
      jumpPressed = control.jumpPressed,
      shootDown = control.shootDown,
      shootPressed = control.shootPressed,
      prevDown = control.prevDown,
      prevPressed = control.prevPressed,
      nextDown = control.nextDown,
      nextPressed = control.nextPressed,
      dashDown = control.dashDown,
      dashPressed = control.dashPressed,
      pressed = control.pressed,
      _openRecQ = control._openRecQ
    }
end

function control.deser(t)
  control.demo = t.demo
  control.anyPressed = t.anyPressed
  control.pressAnyway = t.pressAnyway
  control.anyPressedDuringRec = t.anyPressedDuringRec
  control.recPos = t.recPos
  control.record = t.record
  control.recordInput = t.recordInput
  control.loadedRec = t.loadedRec
  control.loadedRecPos = t.loadedRecPos
  control.keyPressedRec = t.keyPressedRec
  control.gamepadPressedRec = t.gamepadPressedRec
  control.gamepadAxisRec = t.gamepadAxisRec
  control.touchPressedRec = t.touchPressedRec
  control.textInputRec = t.textInputRec
  control.leftDown = t.leftDown
  control.leftPressed = t.leftPressed
  control.rightDown = t.rightDown
  control.rightPressed = t.rightPressed
  control.upDown = t.upDown
  control.upPressed = t.upPressed
  control.downDown = t.downDown
  control.downPressed = t.downPressed
  control.startDown = t.startDown
  control.startPressed = t.startPressed
  control.selectDown = t.selectDown
  control.selectPressed = t.selectPressed
  control.jumpDown = t.jumpDown
  control.jumpPressed = t.jumpPressed
  control.shootDown = t.shootDown
  control.shootPressed = t.shootPressed
  control.prevDown = t.prevDown
  control.prevPressed = t.prevPressed
  control.nextDown = t.nextDown
  control.nextPressed = t.nextPressed
  control.dashDown = t.dashDown
  control.dashPressed = t.dashPressed
  control.pressed = t.pressed
  control._openRecQ = t._openRecQ
end

control._startRecQ = false
control._openRecQ = nil

function control.init()
  control.leftDown = {}
  control.leftPressed = {}
  control.rightDown = {}
  control.rightPressed = {}
  control.upDown = {}
  control.upPressed = {}
  control.downDown = {}
  control.downPressed = {}
  control.startDown = {}
  control.startPressed = {}
  control.selectDown = {}
  control.selectPressed = {}
  control.jumpDown = {}
  control.jumpPressed = {}
  control.shootDown = {}
  control.shootPressed = {}
  control.prevDown = {}
  control.prevPressed = {}
  control.nextDown = {}
  control.nextPressed = {}
  control.dashDown = {}
  control.dashPressed = {}
  
  control.pressed = {}
  for i=1, maxPlayerCount do
    control.leftDown[i] = false
    control.leftPressed[i] = false
    control.rightDown[i] = false
    control.rightPressed[i] = false
    control.upDown[i] = false
    control.upPressed[i] = false
    control.downDown[i] = false
    control.downPressed[i] = false
    control.startDown[i] = false
    control.startPressed[i] = false
    control.selectDown[i] = false
    control.selectPressed[i] = false
    control.jumpDown[i] = false
    control.jumpPressed[i] = false
    control.shootDown[i] = false
    control.shootPressed[i] = false
    control.prevDown[i] = false
    control.prevPressed[i] = false
    control.nextDown[i] = false
    control.nextPressed[i] = false
    control.dashDown[i] = false
    control.dashPressed[i] = false
  end
  
  control.demo = false
  control.pressAnyway = false
  control.anyPressedDuringRec = false
  control.anyPressed = false
  control.record = {data = {}}
  control.recPos = 1
  control.loadedRec = {data = {}}
  control.loadedRecPos = 1
  
  for i=1, maxPlayerCount do
    control.pressed[i] = {}
    control.pressed[i].left = true
    control.pressed[i].right = true
    control.pressed[i].up = true
    control.pressed[i].down = true
    control.pressed[i].jump = true
    control.pressed[i].shoot = true
    control.pressed[i].start = true
    control.pressed[i].selec = true
    control.pressed[i].prev = true
    control.pressed[i].nex = true
    control.pressed[i].dash = true
  end
  
  local defaultInputBinds, defaultInputBindsExtra = control.defaultBindsTable()
  
  local binds = {}
  local step = 0
  
  binds[1] = defaultInputBinds.up
  binds[2] = defaultInputBinds.down
  binds[3] = defaultInputBinds.left
  binds[4] = defaultInputBinds.right
  binds[5] = defaultInputBinds.start
  binds[6] = defaultInputBinds.select
  binds[7] = defaultInputBinds.jump
  binds[8] = defaultInputBinds.shoot
  binds[9] = defaultInputBinds.prev
  binds[10] = defaultInputBinds.next
  binds[11] = defaultInputBinds.dash
  
  step = step + 11
  for i=2, maxPlayerCount do
    if not defaultInputBindsExtra[i] then break end
    binds[1+step] = defaultInputBindsExtra[i].up
    binds[2+step] = defaultInputBindsExtra[i].down
    binds[3+step] = defaultInputBindsExtra[i].left
    binds[4+step] = defaultInputBindsExtra[i].right
    binds[5+step] = defaultInputBindsExtra[i].start
    binds[6+step] = defaultInputBindsExtra[i].select
    binds[7+step] = defaultInputBindsExtra[i].jump
    binds[8+step] = defaultInputBindsExtra[i].shoot
    binds[9+step] = defaultInputBindsExtra[i].prev
    binds[10+step] = defaultInputBindsExtra[i].next
    binds[11+step] = defaultInputBindsExtra[i].dash
    step = step + 11
  end
  
  step = 0
  local data = save.load("main.sav")
  if data and data.controls then
    for i=1, maxPlayerCount do
      binds[1+step] = data.controls[1+step] or binds[1+step]
      binds[2+step] = data.controls[2+step] or binds[2+step]
      binds[3+step] = data.controls[3+step] or binds[3+step]
      binds[4+step] = data.controls[4+step] or binds[4+step]
      binds[5+step] = data.controls[5+step] or binds[5+step]
      binds[6+step] = data.controls[6+step] or binds[6+step]
      binds[7+step] = data.controls[7+step] or binds[7+step]
      binds[8+step] = data.controls[8+step] or binds[8+step]
      binds[9+step] = data.controls[9+step] or binds[9+step]
      binds[10+step] = data.controls[10+step] or binds[10+step]
      binds[11+step] = data.controls[11+step] or binds[11+step]
      step = step + 11
    end
  end
  step = 0
  for i=1, maxPlayerCount do
    if binds[1+step] then
      inputHandler.bind(binds[1+step], 1+step)
      inputHandler.bind(binds[2+step], 2+step)
      inputHandler.bind(binds[3+step], 3+step)
      inputHandler.bind(binds[4+step], 4+step)
      inputHandler.bind(binds[5+step], 5+step)
      inputHandler.bind(binds[6+step], 6+step)
      inputHandler.bind(binds[7+step], 7+step)
      inputHandler.bind(binds[8+step], 8+step)
      inputHandler.bind(binds[9+step], 9+step)
      inputHandler.bind(binds[10+step], 10+step)
      inputHandler.bind(binds[11+step], 11+step)
    end
    step = step + 11
  end
end

function control.defaultBinds()
  inputHandler.unbind()
  
  local defaultInputBinds, defaultInputBindsExtra = control.defaultBindsTable()
  
  local binds = {}
  local step = 0
  
  binds[1] = defaultInputBinds.up
  binds[2] = defaultInputBinds.down
  binds[3] = defaultInputBinds.left
  binds[4] = defaultInputBinds.right
  binds[5] = defaultInputBinds.start
  binds[6] = defaultInputBinds.select
  binds[7] = defaultInputBinds.jump
  binds[8] = defaultInputBinds.shoot
  binds[9] = defaultInputBinds.prev
  binds[10] = defaultInputBinds.next
  binds[11] = defaultInputBinds.dash
  
  step = step + 11
  for i=2, maxPlayerCount do
    if not defaultInputBindsExtra[i] then break end
    binds[1+step] = defaultInputBindsExtra[i].up
    binds[2+step] = defaultInputBindsExtra[i].down
    binds[3+step] = defaultInputBindsExtra[i].left
    binds[4+step] = defaultInputBindsExtra[i].right
    binds[5+step] = defaultInputBindsExtra[i].start
    binds[6+step] = defaultInputBindsExtra[i].select
    binds[7+step] = defaultInputBindsExtra[i].jump
    binds[8+step] = defaultInputBindsExtra[i].shoot
    binds[9+step] = defaultInputBindsExtra[i].prev
    binds[10+step] = defaultInputBindsExtra[i].next
    binds[11+step] = defaultInputBindsExtra[i].dash
    step = step + 11
  end
  
  step = 0
  for i=1, maxPlayerCount do
    if binds[1+step] then
      inputHandler.bind(binds[1+step], 1+step)
      inputHandler.bind(binds[2+step], 2+step)
      inputHandler.bind(binds[3+step], 3+step)
      inputHandler.bind(binds[4+step], 4+step)
      inputHandler.bind(binds[5+step], 5+step)
      inputHandler.bind(binds[6+step], 6+step)
      inputHandler.bind(binds[7+step], 7+step)
      inputHandler.bind(binds[8+step], 8+step)
      inputHandler.bind(binds[9+step], 9+step)
      inputHandler.bind(binds[10+step], 10+step)
      inputHandler.bind(binds[11+step], 11+step)
    end
    step = step + 11
  end
end

function control.loadBinds()
  inputHandler.unbind()
  
  local binds = {}
  local step = 0
  local defaultInputBinds, defaultInputBindsExtra = control.defaultBindsTable()
  
  binds[1] = defaultInputBinds.up
  binds[2] = defaultInputBinds.down
  binds[3] = defaultInputBinds.left
  binds[4] = defaultInputBinds.right
  binds[5] = defaultInputBinds.start
  binds[6] = defaultInputBinds.select
  binds[7] = defaultInputBinds.jump
  binds[8] = defaultInputBinds.shoot
  binds[9] = defaultInputBinds.prev
  binds[10] = defaultInputBinds.next
  binds[11] = defaultInputBinds.dash
  
  step = step + 11
  for i=2, maxPlayerCount do
    if not defaultInputBindsExtra[i] then break end
    binds[1+step] = defaultInputBindsExtra[i].up
    binds[2+step] = defaultInputBindsExtra[i].down
    binds[3+step] = defaultInputBindsExtra[i].left
    binds[4+step] = defaultInputBindsExtra[i].right
    binds[5+step] = defaultInputBindsExtra[i].start
    binds[6+step] = defaultInputBindsExtra[i].select
    binds[7+step] = defaultInputBindsExtra[i].jump
    binds[8+step] = defaultInputBindsExtra[i].shoot
    binds[9+step] = defaultInputBindsExtra[i].prev
    binds[10+step] = defaultInputBindsExtra[i].next
    binds[11+step] = defaultInputBindsExtra[i].dash
    step = step + 11
  end
  
  step = 0
  local data = save.load("main.sav")
  if data and data.controls then
    for i=1, maxPlayerCount do
      binds[1+step] = data.controls[1+step] or binds[1+step]
      binds[2+step] = data.controls[2+step] or binds[2+step]
      binds[3+step] = data.controls[3+step] or binds[3+step]
      binds[4+step] = data.controls[4+step] or binds[4+step]
      binds[5+step] = data.controls[5+step] or binds[5+step]
      binds[6+step] = data.controls[6+step] or binds[6+step]
      binds[7+step] = data.controls[7+step] or binds[7+step]
      binds[8+step] = data.controls[8+step] or binds[8+step]
      binds[9+step] = data.controls[9+step] or binds[9+step]
      binds[10+step] = data.controls[10+step] or binds[10+step]
      binds[11+step] = data.controls[11+step] or binds[11+step]
      step = step + 11
    end
  end
  
  step = 0
  for i=1, maxPlayerCount do
    if binds[1+step] then
      inputHandler.bind(binds[1+step], 1+step)
      inputHandler.bind(binds[2+step], 2+step)
      inputHandler.bind(binds[3+step], 3+step)
      inputHandler.bind(binds[4+step], 4+step)
      inputHandler.bind(binds[5+step], 5+step)
      inputHandler.bind(binds[6+step], 6+step)
      inputHandler.bind(binds[7+step], 7+step)
      inputHandler.bind(binds[8+step], 8+step)
      inputHandler.bind(binds[9+step], 9+step)
      inputHandler.bind(binds[10+step], 10+step)
      inputHandler.bind(binds[11+step], 11+step)
    end
    step = step + 11
  end
end

function control.resetRec()
  control.recPos = 1
  control.record = {data = {}}
  control.anyPressed = false
  control.recordInput = false
  control.updateDemoFunc = nil
  control.drawDemoFunc = nil
end

function control.startRecQ(f)
  control._startRecQ = f == nil or f
end

function control.startRec()
  control.resetRec()
  
  control.record.context = ser()
  control.recordInput = true
end

function control.finishRecord(name)
  control.record.last = control.recPos
  save.save(name, control.record)
  
  control.resetRec()
end

function control.resetLoadedRec()
  control.pressed = {}
  for i=1, maxPlayerCount do
    control.pressed[i] = {}
    control.pressed[i].left = true
    control.pressed[i].right = true
    control.pressed[i].up = true
    control.pressed[i].down = true
    control.pressed[i].jump = true
    control.pressed[i].shoot = true
    control.pressed[i].start = true
    control.pressed[i].selec = true
    control.pressed[i].prev = true
    control.pressed[i].nex = true
    control.pressed[i].dash = true
  end
  control.loadedRecPos = 1
  control.loadedRecord = {data = {}}
  control.anyPressed = false
  control.pressAnyway = false
  control.demo = false
end

function control.openRecQ(f)
  control._openRecQ = f
end

function control.openRec(f)
  control.resetLoadedRec()
  local file = save.load(f)
  control.oldContext = ser()
  
  deser(file.context)
  
  control.recPos = 1
  control.record = {data = {}}
  control.recordInput = false
  control.loadedRec = file
  control.demo = true
end

function control.update()
  if not control.demo then
    local step = 0
    for i=1, globals.playerCount do
      control.leftDown[i] = inputHandler.down(3+step)
      control.leftPressed[i] = inputHandler.pressed(3+step)
      control.rightDown[i] = inputHandler.down(4+step)
      control.rightPressed[i] = inputHandler.pressed(4+step)
      control.upDown[i] = inputHandler.down(1+step)
      control.upPressed[i] = inputHandler.pressed(1+step)
      control.downDown[i] = inputHandler.down(2+step)
      control.downPressed[i] = inputHandler.pressed(2+step)
      control.startDown[i] = inputHandler.down(5+step)
      control.startPressed[i] = inputHandler.pressed(5+step)
      control.selectDown[i] = inputHandler.down(6+step)
      control.selectPressed[i] = inputHandler.pressed(6+step)
      control.jumpDown[i] = inputHandler.down(7+step)
      control.jumpPressed[i] = inputHandler.pressed(7+step)
      control.shootDown[i] = inputHandler.down(8+step)
      control.shootPressed[i] = inputHandler.pressed(8+step)
      control.prevDown[i] = inputHandler.down(9+step)
      control.prevPressed[i] = inputHandler.pressed(9+step)
      control.nextDown[i] = inputHandler.down(10+step)
      control.nextPressed[i] = inputHandler.pressed(10+step)
      control.dashDown[i] = inputHandler.down(11+step)
      control.dashPressed[i] = inputHandler.pressed(11+step)
      step = step + 11
    end
  else
    control.playRecord()
    local result = false
    result = control.updateDemo()
    if control.loadedRecPos >= control.loadedRec.last then
      result = true
    end
    if result then
      control.resetLoadedRec()
      
      if control.returning then
        control.returning()
        control.returning = nil
      else
        deserQueue = function()
          control.demo = false
          local c = control.oldContext
          control.oldContext = nil
          return c
        end
      end
    end
  end
  if control.recordInput then
    control.doRecording()
  end
end

function control.playRecord()
  if control.loadedRec.data[control.loadedRecPos] then
    for i=1, globals.playerCount do
      control.leftDown[i] = control.loadedRec.data[control.loadedRecPos].ld and control.loadedRec.data[control.loadedRecPos].ld[i]
      control.leftPressed[i] = control.leftDown[i] and control.pressed[i].left
      if control.leftPressed[i] then control.pressed[i].left = false end
      control.rightDown[i] = control.loadedRec.data[control.loadedRecPos].rd and control.loadedRec.data[control.loadedRecPos].rd[i]
      control.rightPressed[i] = control.rightDown[i] and control.pressed[i].right
      if control.rightPressed[i] then control.pressed[i].right = false end
      control.upDown[i] = control.loadedRec.data[control.loadedRecPos].ud and control.loadedRec.data[control.loadedRecPos].ud[i]
      control.upPressed[i] = control.upDown[i] and control.pressed[i].up
      if control.upPressed[i] then control.pressed[i].up = false end
      control.downDown[i] = control.loadedRec.data[control.loadedRecPos].dd and control.loadedRec.data[control.loadedRecPos].dd[i]
      control.downPressed[i] = control.downDown[i] and control.pressed[i].down
      if control.downPressed[i] then control.pressed[i].down = false end
      control.startDown[i] = control.loadedRec.data[control.loadedRecPos].sd and control.loadedRec.data[control.loadedRecPos].sd[i]
      control.startPressed[i] = control.startDown[i] and control.pressed[i].start
      if control.startPressed[i] then control.pressed[i].start = false end
      control.selectDown[i] = control.loadedRec.data[control.loadedRecPos].sld and control.loadedRec.data[control.loadedRecPos].sld[i]
      control.selectPressed[i] = control.selectDown[i] and control.pressed[i].selec
      if control.selectPressed[i] then control.pressed[i].selec = false end
      control.jumpDown[i] = control.loadedRec.data[control.loadedRecPos].jd and control.loadedRec.data[control.loadedRecPos].jd[i]
      control.jumpPressed[i] = control.jumpDown[i] and control.pressed[i].jump
      if control.jumpPressed[i] then control.pressed[i].jump = false end
      control.shootDown[i] = control.loadedRec.data[control.loadedRecPos].shd and control.loadedRec.data[control.loadedRecPos].shd[i]
      control.shootPressed[i] = control.shootDown[i] and control.pressed[i].shoot
      if control.shootPressed[i] then control.pressed[i].shoot = false end
      control.prevDown[i] = control.loadedRec.data[control.loadedRecPos].pd and control.loadedRec.data[control.loadedRecPos].pd[i]
      control.prevPressed[i] = control.prevDown[i] and control.pressed[i].prev
      if control.prevPressed[i] then control.pressed[i].prev = false end
      control.nextDown[i] = control.loadedRec.data[control.loadedRecPos].nd and control.loadedRec.data[control.loadedRecPos].nd[i]
      control.nextPressed[i] = control.nextDown[i] and control.pressed[i].nex
      if control.nextPressed[i] then control.pressed[i].nex = false end
      control.dashDown[i] = control.loadedRec.data[control.loadedRecPos].dad and control.loadedRec.data[control.loadedRecPos].dad[i]
      control.dashPressed[i] = control.dashDown[i] and control.pressed[i].dash
      if control.dashPressed[i] then control.pressed[i].dash = false end
    end
    control.pressAnyway = true
    if control.loadedRec.data[control.loadedRecPos].kp then
      for i=1, #control.loadedRec.data[control.loadedRecPos].kp do
        love.keypressed(unpack(control.loadedRec.data[control.loadedRecPos].kp[i]))
      end
    end
    if control.loadedRec.data[control.loadedRecPos].gpp then
      for i=1, #control.loadedRec.data[control.loadedRecPos].gpp do
        love.gamepadpressed(unpack(control.loadedRec.data[control.loadedRecPos].gpp[i]))
      end
    end
    if control.loadedRec.data[control.loadedRecPos].gpa then
      for i=1, #control.loadedRec.data[control.loadedRecPos].gpa do
        love.keypressed(unpack(control.loadedRec.data[control.loadedRecPos].gpa[i]))
      end
    end
    if control.loadedRec.data[control.loadedRecPos].tp then
      for i=1, #control.loadedRec.data[control.loadedRecPos].tp do
        love.touchpressed(unpack(control.loadedRec.data[control.loadedRecPos].tp[i]))
      end
    end
    if control.loadedRec.data[control.loadedRecPos].ti then
      for i=1, #control.loadedRec.data[control.loadedRecPos].ti do
        love.textinput(control.loadedRec.data[control.loadedRecPos].ti[i])
      end
    end
    control.pressAnyway = false
  else
    for i=1, globals.playerCount do
      control.leftDown[i] = false
      control.leftPressed[i] = false
      control.rightDown[i] = false
      control.rightPressed[i] = false
      control.upDown[i] = false
      control.upPressed[i] = false
      control.downDown[i] = false
      control.downPressed[i] = false
      control.startDown[i] = false
      control.startPressed[i] = false
      control.selectDown[i] = false
      control.selectPressed[i] = false
      control.jumpDown[i] = false
      control.jumpPressed[i] = false
      control.shootDown[i] = false
      control.shootPressed[i] = false
      control.prevDown[i] = false
      control.prevPressed[i] = false
      control.nextDown[i] = false
      control.nextPressed[i] = false
      control.dashDown[i] = false
      control.dashPressed[i] = false
    end
  end
  control.loadedRecPos = control.loadedRecPos + 1
end

function control.doRecording()
  for i=1, globals.playerCount do
    if control.leftDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].ld == nil then
        control.record.data[control.recPos].ld = {}
      end
      control.record.data[control.recPos].ld[i] = control.leftDown[i]
    end
    if control.rightDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].rd == nil then
        control.record.data[control.recPos].rd = {}
      end
      control.record.data[control.recPos].rd[i] = control.rightDown[i]
    end
    if control.upDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].ud == nil then
        control.record.data[control.recPos].ud = {}
      end
      control.record.data[control.recPos].ud[i] = control.upDown[i]
    end
    if control.downDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].dd == nil then
        control.record.data[control.recPos].dd = {}
      end
      control.record.data[control.recPos].dd[i] = control.downDown[i]
    end
    if control.startDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].sd == nil then
        control.record.data[control.recPos].sd = {}
      end
      control.record.data[control.recPos].sd[i] = control.startDown[i]
    end
    if control.selectDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].sld == nil then
        control.record.data[control.recPos].sld = {}
      end
      control.record.data[control.recPos].sld[i] = control.selectDown[i]
    end
    if control.jumpDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].jd == nil then
        control.record.data[control.recPos].jd = {}
      end
      control.record.data[control.recPos].jd[i] = control.jumpDown[i]
    end
    if control.shootDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].shd == nil then
        control.record.data[control.recPos].shd = {}
      end
      control.record.data[control.recPos].shd[i] = control.shootDown[i]
    end
    if control.prevDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].pd == nil then
        control.record.data[control.recPos].pd = {}
      end
      control.record.data[control.recPos].pd[i] = control.prevDown[i]
    end
    if control.nextDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].nd == nil then
        control.record.data[control.recPos].nd = {}
      end
      control.record.data[control.recPos].nd[i] = control.nextDown[i]
    end
    if control.dashDown[i] then
      if control.record.data[control.recPos] == nil then
        control.record.data[control.recPos] = {}
      end
      if control.record.data[control.recPos].dad == nil then
        control.record.data[control.recPos].dad = {}
      end
      control.record.data[control.recPos].dad[i] = control.dashDown[i]
    end
  end
  
  if control.keyPressedRec then
    if control.record.data[control.recPos] == nil then
      control.record.data[control.recPos] = {}
    end
    control.record.data[control.recPos].kp = control.keyPressedRec
    control.keyPressedRec = nil
  end
  if control.gamepadPressedRec then
    if control.record.data[control.recPos] == nil then
      control.record.data[control.recPos] = {}
    end
    control.record.data[control.recPos].gpp = control.gamepadPressedRec
    control.gamepadPressedRec = nil
  end
  if control.gamepadAxisRec then
    if control.record.data[control.recPos] == nil then
      control.record.data[control.recPos] = {}
    end
    control.record.data[control.recPos].gpa = control.gamepadAxisRec
    control.gamepadAxisRec = nil
  end
  if control.touchPressedRec then
    if control.record.data[control.recPos] == nil then
      control.record.data[control.recPos] = {}
    end
    control.record.data[control.recPos].tp = control.touchPressedRec
    control.touchPressedRec = nil
  end
  if control.textInputRec then
    if control.record.data[control.recPos] == nil then
      control.record.data[control.recPos] = {}
    end
    control.record.data[control.recPos].ti = control.textInputRec
    control.textInputRec = nil
  end
  
  control.recPos = control.recPos + 1
  
  if control.updateDemo() then
    console.parse("recend")
    if console.state == 0 then
      console.open()
    end
  end
end

function control.updateDemo()
  if control.updateDemoFunc then
    return control.updateDemoFunc()
  else
    if control.demo then
      return control.anyPressedDuringRec
    else
      return lastPressed and lastPressed.input == "backspace"
    end
  end
end

function control.drawDemo()
  if control.drawDemoFunc then
    control.drawDemoFunc()
  else
    if control.demo then
      love.graphics.setColor(0, 0, 0, 0.4)
      love.graphics.rectangle("fill", view.w-144, view.h-24, 144, 16)
      love.graphics.setColor(1, 1, 1, 0.4)
      love.graphics.print("REPLAY", view.w - 64, view.h - 24)
      love.graphics.print("ANY BUTTON TO END", view.w - 142, view.h - 16)
    elseif control.recordInput then
      love.graphics.setColor(0, 0, 0, 0.4)
      love.graphics.rectangle("fill", view.w-134, view.h-24, 142, 16)
      love.graphics.setColor(1, 1, 1, 0.4)
      love.graphics.print("RECORDING", view.w - 88, view.h - 24)
      love.graphics.print("BACKSPACE TO END", view.w - 132, view.h - 16)
    end
  end
end

function control.flush()
  inputHandler.flush()
  if control.demo then
    for i=1, globals.playerCount do
      if not control.leftDown[i] then control.pressed[i].left = true end
      if not control.rightDown[i] then control.pressed[i].right = true end
      if not control.upDown[i] then control.pressed[i].up = true end
      if not control.downDown[i] then control.pressed[i].down = true end
      if not control.jumpDown[i] then control.pressed[i].jump = true end
      if not control.shootDown[i] then control.pressed[i].shoot = true end
      if not control.startDown[i] then control.pressed[i].start = true end
      if not control.selectDown[i] then control.pressed[i].selec = true end
      if not control.prevDown[i] then control.pressed[i].prev = true end
      if not control.nextDown[i] then control.pressed[i].nex = true end
      if not control.dashDown[i] then control.pressed[i].dash = true end
    end
  end
  control.anyPressed = false
end
