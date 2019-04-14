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
  
  local step = 0
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
    step = step + 11
  end
  
  control.demo = false
  control.record = {}
  control.recPos = 1
  control.recordInput = false
  control.anyPressed = false
  
  inputHandler.init()
  
  local data = save.load("main.sav", true)
  local binds = {}
  step = 0
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
    
    binds[12] = defaultInputBinds2.up
    binds[13] = defaultInputBinds2.down
    binds[14] = defaultInputBinds2.left
    binds[15] = defaultInputBinds2.right
    binds[16] = defaultInputBinds2.start
    binds[17] = defaultInputBinds2.select
    binds[18] = defaultInputBinds2.jump
    binds[19] = defaultInputBinds2.shoot
    binds[20] = defaultInputBinds2.prev
    binds[21] = defaultInputBinds2.next
    binds[22] = defaultInputBinds2.dash
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
  end
  step = 0
  for i=1, maxPlayerCount do
    if binds[1+step] then
      inputHandler.bind(binds[1+step][1], 1+step, binds[1+step][2], binds[1+step][3])
      inputHandler.bind(binds[2+step][1], 2+step, binds[2+step][2], binds[1+step][3])
      inputHandler.bind(binds[3+step][1], 3+step, binds[3+step][2], binds[1+step][3])
      inputHandler.bind(binds[4+step][1], 4+step, binds[4+step][2], binds[1+step][3])
      inputHandler.bind(binds[5+step][1], 5+step, binds[5+step][2], binds[1+step][3])
      inputHandler.bind(binds[6+step][1], 6+step, binds[6+step][2], binds[1+step][3])
      inputHandler.bind(binds[7+step][1], 7+step, binds[7+step][2], binds[1+step][3])
      inputHandler.bind(binds[8+step][1], 8+step, binds[8+step][2], binds[1+step][3])
      inputHandler.bind(binds[9+step][1], 9+step, binds[9+step][2], binds[1+step][3])
      inputHandler.bind(binds[10+step][1], 10+step, binds[10+step][2], binds[1+step][3])
      inputHandler.bind(binds[11+step][1], 11+step, binds[11+step][2], binds[1+step][3])
    end
    step = step + 11
  end
end

function control.update()
  if not control.demo then
    if touchControls then
      touchInput.update()
    end
    local step = 0
    for i=1, playerCount do
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
    if control.record.last <= control.recPos then
      result = true
    end
    if result and not control.once then
      control.once = true
      control.demo = false
      control.recPos = 1
      control.record = {}
      megautils.loadGame(control.lastGame)
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
  result.gamePath = control.record.gamePath
  if love.filesystem.getInfo(control.recordName .. ".rd") then
    love.filesystem.remove(control.recordName .. ".rd")
  end
  save.save(control.recordName .. ".rd", result, true)
  control.record = {}
  control.recPos = 1
  control.globals = nil
  control.gamePath = nil
end

function control.playRecord()
  if control.record[control.recPos] then
    for i=1, maxPlayerCount do
      control.leftDown[i] = control.record[control.recPos].leftDown and control.record[control.recPos].leftDown[i] == 1
      control.leftPressed[i] = control.record[control.recPos].leftPressed and control.record[control.recPos].leftPressed[i] == 1
      control.rightDown[i] = control.record[control.recPos].rightDown and control.record[control.recPos].rightDown[i] == 1
      control.rightPressed[i] = control.record[control.recPos].rightPressed and control.record[control.recPos].rightPressed[i] == 1
      control.upDown[i] = control.record[control.recPos].upDown and control.record[control.recPos].upDown[i] == 1
      control.upPressed[i] = control.record[control.recPos].upPressed and control.record[control.recPos].upPressed[i] == 1
      control.downDown[i] = control.record[control.recPos].downDown and control.record[control.recPos].downDown[i] == 1
      control.downPressed[i] = control.record[control.recPos].downPressed and control.record[control.recPos].downPressed[i] == 1
      control.startDown[i] = control.record[control.recPos].startDown and control.record[control.recPos].startDown[i] == 1
      control.startPressed[i] = control.record[control.recPos].startPressed and control.record[control.recPos].startPressed[i] == 1
      control.selectDown[i] = control.record[control.recPos].selectDown and control.record[control.recPos].selectDown[i] == 1
      control.selectPressed[i] = control.record[control.recPos].selectPressed and control.record[control.recPos].selectPressed[i] == 1
      control.jumpDown[i] = control.record[control.recPos].jumpDown and control.record[control.recPos].jumpDown[i] == 1
      control.jumpPressed[i] = control.record[control.recPos].jumpPressed and control.record[control.recPos].jumpPressed[i] == 1
      control.shootDown[i] = control.record[control.recPos].shootDown and control.record[control.recPos].shootDown[i] == 1
      control.shootPressed[i] = control.record[control.recPos].shootPressed and control.record[control.recPos].shootPressed[i] == 1
      control.prevDown[i] = control.record[control.recPos].prevDown and control.record[control.recPos].prevDown[i] == 1
      control.prevPressed[i] = control.record[control.recPos].prevPressed and control.record[control.recPos].prevPressed[i] == 1
      control.nextDown[i] = control.record[control.recPos].nextDown and control.record[control.recPos].nextDown[i] == 1
      control.nextPressed[i] = control.record[control.recPos].nextPressed and control.record[control.recPos].nextPressed[i] == 1
      control.dashDown[i] = control.record[control.recPos].dashDown and control.record[control.recPos].dashDown[i] == 1
      control.dashPressed[i] = control.record[control.recPos].dashPressed and control.record[control.recPos].dashPressed[i] == 1
    end
  else
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
  end
  control.recPos = control.recPos + 1
end

function control.loadRecord(file)
  control.record = table.stringtonumberkeys(save.load(file, true))
  control.recPos = 1
end

function control.drawDemo()
  if control.demo and math.wrap(control.recPos, 0, 40) < 20 then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(mmFont)
    love.graphics.print("replay", 8, 8)
  elseif control.recordInput and control.recPos < 120 then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(mmFont)
    love.graphics.print("recording", 8, 8)
  end
end

function control.doRecording()
  for i=1, playerCount do
    if control.leftDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].leftDown == nil then
        control.record[control.recPos].leftDown = {}
      end
      control.record[control.recPos].leftDown[i] = 1
    end
    if control.leftPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].leftPressed == nil then
        control.record[control.recPos].leftPressed = {}
      end
      control.record[control.recPos].leftPressed[i] = 1
    end
    if control.rightDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].rightDown == nil then
        control.record[control.recPos].rightDown = {}
      end
      control.record[control.recPos].rightDown[i] = 1
    end
    if control.rightPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].rightPressed == nil then
        control.record[control.recPos].rightPressed = {}
      end
      control.record[control.recPos].rightPressed[i] = 1
    end
    if control.upDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].upDown == nil then
        control.record[control.recPos].upDown = {}
      end
      control.record[control.recPos].upDown[i] = 1
    end
    if control.upPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].upPressed == nil then
        control.record[control.recPos].upPressed = {}
      end
      control.record[control.recPos].upPressed[i] = 1
    end
    if control.downDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].downDown == nil then
        control.record[control.recPos].downDown = {}
      end
      control.record[control.recPos].downDown[i] = 1
    end
    if control.downPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].downPressed == nil then
        control.record[control.recPos].downPressed = {}
      end
      control.record[control.recPos].downPressed[i] = 1
    end
    if control.startDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].startDown == nil then
        control.record[control.recPos].startDown = {}
      end
      control.record[control.recPos].startDown[i] = 1
    end
    if control.startPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].startPressed == nil then
        control.record[control.recPos].startPressed = {}
      end
      control.record[control.recPos].startPressed[i] = 1
    end
    if control.selectDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].selectDown == nil then
        control.record[control.recPos].selectDown = {}
      end
      control.record[control.recPos].selectDown[i] = 1
    end
    if control.selectPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].selectPressed == nil then
        control.record[control.recPos].selectPressed = {}
      end
      control.record[control.recPos].selectPressed[i] = 1
    end
    if control.jumpDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].jumpDown == nil then
        control.record[control.recPos].jumpDown = {}
      end
      control.record[control.recPos].jumpDown[i] = 1
    end
    if control.jumpPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].jumpPressed == nil then
        control.record[control.recPos].jumpPressed = {}
      end
      control.record[control.recPos].jumpPressed[i] = 1
    end
    if control.shootDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].shootDown == nil then
        control.record[control.recPos].shootDown = {}
      end
      control.record[control.recPos].shootDown[i] = 1
    end
    if control.shootPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].shootPressed == nil then
        control.record[control.recPos].shootPressed = {}
      end
      control.record[control.recPos].shootPressed[i] = 1
    end
    if control.prevDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].prevDown == nil then
        control.record[control.recPos].prevDown = {}
      end
      control.record[control.recPos].prevDown[i] = 1
    end
    if control.prevPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].prevPressed == nil then
        control.record[control.recPos].prevPressed = {}
      end
      control.record[control.recPos].prevPressed[i] = 1
    end
    if control.nextDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].nextDown == nil then
        control.record[control.recPos].nextDown = {}
      end
      control.record[control.recPos].nextDown[i] = 1
    end
    if control.nextPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].nextPressed == nil then
        control.record[control.recPos].nextPressed = {}
      end
      control.record[control.recPos].nextPressed[i] = 1
    end
    if control.dashDown[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].dashDown == nil then
        control.record[control.recPos].dashDown = {}
      end
      control.record[control.recPos].dashDown[i] = 1
    end
    if control.dashPressed[i] then
      if control.record[control.recPos] == nil then
        control.record[control.recPos] = {}
      end
      if control.record[control.recPos].dashPressed == nil then
        control.record[control.recPos].dashPressed = {}
      end
      control.record[control.recPos].dashPressed[i] = 1
    end
  end
  control.recPos = control.recPos + 1
end

function control.flush()
  inputHandler.flush()
  touchInput.flush()
  control.anyPressed = false
end
