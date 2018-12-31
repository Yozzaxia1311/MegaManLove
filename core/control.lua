control = {}

control.inputBinds = {}

function control.init()
  control.leftDown = false
  control.leftPressed = false
  control.rightDown = false
  control.rightPressed = false
  control.upDown = false
  control.upPressed = false
  control.downDown = false
  control.downPressed = false
  control.startDown = false
  control.startPressed = false
  control.selectDown = false
  control.selectPressed = false
  control.jumpDown = false
  control.jumpPressed = false
  control.shootDown = false
  control.shootPressed = false
  control.prevDown = false
  control.prevPressed = false
  control.nextDown = false
  control.nextPressed = false
  control.dashDown = false
  control.dashPressed = false
  
  inputHandler.init()
  
  local data = save.load("main.set")
  local binds = {}
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
    binds[1] = data.controls[1]
    binds[2] = data.controls[2]
    binds[3] = data.controls[3]
    binds[4] = data.controls[4]
    binds[5] = data.controls[5]
    binds[6] = data.controls[6]
    binds[7] = data.controls[7]
    binds[8] = data.controls[8]
    binds[9] = data.controls[9]
    binds[10] = data.controls[10]
    binds[11] = data.controls[11]
  end
  inputHandler.bind(binds[1][1], 1, binds[1][2])
  inputHandler.bind(binds[2][1], 2, binds[2][2])
  inputHandler.bind(binds[3][1], 3, binds[3][2])
  inputHandler.bind(binds[4][1], 4, binds[4][2])
  inputHandler.bind(binds[5][1], 5, binds[5][2])
  inputHandler.bind(binds[6][1], 6, binds[6][2])
  inputHandler.bind(binds[7][1], 7, binds[7][2])
  inputHandler.bind(binds[8][1], 8, binds[8][2])
  inputHandler.bind(binds[9][1], 9, binds[9][2])
  inputHandler.bind(binds[10][1], 10, binds[10][2])
  inputHandler.bind(binds[11][1], 11, binds[11][2])
end

function control.update()
  control.leftDown = false
  control.leftPressed = false
  control.rightDown = false
  control.rightPressed = false
  control.upDown = false
  control.upPressed = false
  control.downDown = false
  control.downPressed = false
  control.startDown = false
  control.startPressed = false
  control.selectDown = false
  control.selectPressed = false
  control.jumpDown = false
  control.jumpPressed = false
  control.shootDown = false
  control.shootPressed = false
  control.prevDown = false
  control.prevPressed = false
  control.nextDown = false
  control.nextPressed = false
  control.dashDown = false
  control.dashPressed = false
  
  if touchControls then
    touchInput.update()
  end
  
  control.leftDown = inputHandler.down(3)
  control.leftPressed = inputHandler.pressed(3)
  control.rightDown = inputHandler.down(4)
  control.rightPressed = inputHandler.pressed(4)
  control.upDown = inputHandler.down(1)
  control.upPressed = inputHandler.pressed(1)
  control.downDown = inputHandler.down(2)
  control.downPressed = inputHandler.pressed(2)
  control.startDown = inputHandler.down(5)
  control.startPressed = inputHandler.pressed(5)
  control.selectDown = inputHandler.down(6)
  control.selectPressed = inputHandler.pressed(6)
  control.jumpDown = inputHandler.down(7)
  control.jumpPressed = inputHandler.pressed(7)
  control.shootDown = inputHandler.down(8)
  control.shootPressed = inputHandler.pressed(8)
  control.prevDown = inputHandler.down(9)
  control.prevPressed = inputHandler.pressed(9)
  control.nextDown = inputHandler.down(10)
  control.nextPressed = inputHandler.pressed(10)
  control.dashDown = inputHandler.down(11)
  control.dashPressed = inputHandler.pressed(11)
end

function control.flush()
  inputHandler.flush()
  touchInput.flush()
end