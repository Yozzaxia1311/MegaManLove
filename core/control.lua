control = {}

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
  control.resetRec()
  
  inputHandler.init()
  
  local data = save.load("main.sav", true)
  local binds = {}
  local step = 0
  if not data or not data.controls then
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
    control.usesDefaultBinds = true
  else
    for i=1, maxPlayerCount do
      binds[1+step] = data.controls[1+step]
      binds[2+step] = data.controls[2+step]
      binds[3+step] = data.controls[3+step]
      binds[4+step] = data.controls[4+step]
      binds[5+step] = data.controls[5+step]
      binds[6+step] = data.controls[6+step]
      binds[7+step] = data.controls[7+step]
      binds[8+step] = data.controls[8+step]
      binds[9+step] = data.controls[9+step]
      binds[10+step] = data.controls[10+step]
      binds[11+step] = data.controls[11+step]
      step = step + 11
    end
    control.usesDefaultBinds = false
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
  control.recPos = 1
  control.record = {}
  control.anyPressed = false
  control.recordInput = false
  control.once = false
end

function control.update()
  if not control.demo then
    if touchControls then
      touchInput.update()
    end
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
    local result = control.anyPressed
    if control.recPos >= control.record.last then
      result = true
    end
    if result and not control.once then
      control.once = true
      control.demo = false
      control.recPos = 1
      control.record = {}
      if control.returning then control.returning() control.returning = nil else megautils.resetGame() end
    end
  end
  if control.recordInput then
    control.doRecording()
  end
end

function control.finishRecord()
  control.recordInput = false
  local result =  table.numbertostringkeys(control.record)
  result.last = control.recPos
  result.globals = control.record.globals
  result.seed = control.record.seed
  if love.filesystem.getInfo(control.recordName .. ".rd") then
    love.filesystem.remove(control.recordName .. ".rd")
  end
  save.save(control.recordName .. ".rd", result)
  control.record = {}
  control.recPos = 1
  control.globals = nil
end

function control.playRecord()
  if control.record[control.recPos] then
    for i=1, globals.playerCount do
      control.leftDown[i] = control.record[control.recPos].ld and control.record[control.recPos].ld[i]
      control.leftPressed[i] = control.leftDown[i] and control.pressed[i].left
      if control.leftPressed[i] then control.pressed[i].left = false end
      control.rightDown[i] = control.record[control.recPos].rd and control.record[control.recPos].rd[i]
      control.rightPressed[i] = control.rightDown[i] and control.pressed[i].right
      if control.rightPressed[i] then control.pressed[i].right = false end
      control.upDown[i] = control.record[control.recPos].ud and control.record[control.recPos].ud[i]
      control.upPressed[i] = control.upDown[i] and control.pressed[i].up
      if control.upPressed[i] then control.pressed[i].up = false end
      control.downDown[i] = control.record[control.recPos].dd and control.record[control.recPos].dd[i]
      control.downPressed[i] = control.downDown[i] and control.pressed[i].down
      if control.downPressed[i] then control.pressed[i].down = false end
      control.startDown[i] = control.record[control.recPos].sd and control.record[control.recPos].sd[i]
      control.startPressed[i] = control.startDown[i] and control.pressed[i].start
      if control.startPressed[i] then control.pressed[i].start = false end
      control.selectDown[i] = control.record[control.recPos].sld and control.record[control.recPos].sld[i]
      control.selectPressed[i] = control.selectDown[i] and control.pressed[i].selec
      if control.selectPressed[i] then control.pressed[i].selec = false end
      control.jumpDown[i] = control.record[control.recPos].jd and control.record[control.recPos].jd[i]
      control.jumpPressed[i] = control.jumpDown[i] and control.pressed[i].jump
      if control.jumpPressed[i] then control.pressed[i].jump = false end
      control.shootDown[i] = control.record[control.recPos].shd and control.record[control.recPos].shd[i]
      control.shootPressed[i] = control.shootDown[i] and control.pressed[i].shoot
      if control.shootPressed[i] then control.pressed[i].shoot = false end
      control.prevDown[i] = control.record[control.recPos].pd and control.record[control.recPos].pd[i]
      control.prevPressed[i] = control.prevDown[i] and control.pressed[i].prev
      if control.prevPressed[i] then control.pressed[i].prev = false end
      control.nextDown[i] = control.record[control.recPos].nd and control.record[control.recPos].nd[i]
      control.nextPressed[i] = control.nextDown[i] and control.pressed[i].nex
      if control.nextPressed[i] then control.pressed[i].nex = false end
      control.dashDown[i] = control.record[control.recPos].dad and control.record[control.recPos].dad[i]
      control.dashPressed[i] = control.dashDown[i] and control.pressed[i].dash
      if control.dashPressed[i] then control.pressed[i].dash = false end
    end
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
  control.recPos = control.recPos + 1
end

function control.drawDemo()
  if control.demo and math.wrap(control.recPos, 0, 40) < 20 then
    love.graphics.setFont(mmFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("replay", view.w - 64, view.h - 16)
  elseif control.recordInput then
    love.graphics.setFont(mmFont)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("recording", view.w - 88, view.h - 16)
  end
end

function control.doRecording()
  for i=1, globals.playerCount do
    if control.leftDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].ld == nil then
        control.record[control.recPos].ld = {}
      end
      control.record[control.recPos].ld[i] = control.leftDown[i]
    end
    if control.rightDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].rd == nil then
        control.record[control.recPos].rd = {}
      end
      control.record[control.recPos].rd[i] = control.rightDown[i]
    end
    if control.upDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].ud == nil then
        control.record[control.recPos].ud = {}
      end
      control.record[control.recPos].ud[i] = control.upDown[i]
    end
    if control.downDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].dd == nil then
        control.record[control.recPos].dd = {}
      end
      control.record[control.recPos].dd[i] = control.downDown[i]
    end
    if control.startDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].sd == nil then
        control.record[control.recPos].sd = {}
      end
      control.record[control.recPos].sd[i] = control.startDown[i]
    end
    if control.selectDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].sld == nil then
        control.record[control.recPos].sld = {}
      end
      control.record[control.recPos].sld[i] = control.selectDown[i]
    end
    if control.jumpDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].jd == nil then
        control.record[control.recPos].jd = {}
      end
      control.record[control.recPos].jd[i] = control.jumpDown[i]
    end
    if control.shootDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].shd == nil then
        control.record[control.recPos].shd = {}
      end
      control.record[control.recPos].shd[i] = control.shootDown[i]
    end
    if control.prevDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].pd == nil then
        control.record[control.recPos].pd = {}
      end
      control.record[control.recPos].pd[i] = control.prevDown[i]
    end
    if control.nextDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].nd == nil then
        control.record[control.recPos].nd = {}
      end
      control.record[control.recPos].nd[i] = control.nextDown[i]
    end
    if control.dashDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].dad == nil then
        control.record[control.recPos].dad = {}
      end
      control.record[control.recPos].dad[i] = control.dashDown[i]
    end
  end
  control.recPos = control.recPos + 1
end

function control.flush()
  inputHandler.flush()
  touchInput.flush()
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
