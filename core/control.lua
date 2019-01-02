control = {}

control.inputBinds = {}

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
  for i=1, globals.maxPlayerCount do
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
  
  inputHandler.init()
  
  local data = save.load("main.set")
  local binds = {}
  step = 0
  if data == nil then
    binds[1] = control.inputBinds.up
    binds[2] = control.inputBinds.down
    binds[3] = control.inputBinds.left
    binds[4] = control.inputBinds.right
    binds[5] = control.inputBinds.start
    binds[6] = control.inputBinds.select
    binds[7] = control.inputBinds.jump
    binds[8] = control.inputBinds.shoot
    binds[9] = control.inputBinds.prev
    binds[10] = control.inputBinds.next
    binds[11] = control.inputBinds.dash
  else
    for i=1, globals.maxPlayerCount do
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
  for i=1, globals.maxPlayerCount do
    if binds[1+step] then
      inputHandler.bind(binds[1+step][1], 1+step, binds[1+step][2])
      inputHandler.bind(binds[2+step][1], 2+step, binds[2+step][2])
      inputHandler.bind(binds[3+step][1], 3+step, binds[3+step][2])
      inputHandler.bind(binds[4+step][1], 4+step, binds[4+step][2])
      inputHandler.bind(binds[5+step][1], 5+step, binds[5+step][2])
      inputHandler.bind(binds[6+step][1], 6+step, binds[6+step][2])
      inputHandler.bind(binds[7+step][1], 7+step, binds[7+step][2])
      inputHandler.bind(binds[8+step][1], 8+step, binds[8+step][2])
      inputHandler.bind(binds[9+step][1], 9+step, binds[9+step][2])
      inputHandler.bind(binds[10+step][1], 10+step, binds[10+step][2])
      inputHandler.bind(binds[11+step][1], 11+step, binds[11+step][2])
    end
    step = step + 11
  end
end

function control.update()
  local step = 0
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
    step = step + 11
  end
  
  if touchControls then
    touchInput.update()
  end
  
  step = 0
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
end

function control.flush()
  inputHandler.flush()
  touchInput.flush()
end