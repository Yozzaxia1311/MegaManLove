control = {}

control.keyboardControls = {}

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
  
  touchInput.init(love.graphics.getWidth(), love.graphics.getHeight())
  control.input = inputHandler()
  control.initKeyboard()
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
  control.updateKeyboard()
end

--Keyboard
function control.initKeyboard()
  local data = save.load("main.set")
  local binds = {}
  if data == nil then
    binds[1] = control.keyboardControls.up
    binds[2] = control.keyboardControls.down
    binds[3] = control.keyboardControls.left
    binds[4] = control.keyboardControls.right
    binds[5] = control.keyboardControls.start
    binds[6] = control.keyboardControls.select
    binds[7] = control.keyboardControls.jump
    binds[8] = control.keyboardControls.shoot
    binds[9] = control.keyboardControls.prev
    binds[10] = control.keyboardControls.next
    binds[11] = control.keyboardControls.dash
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
  control.input:bind(binds[1][1], 1, binds[1][2])
  control.input:bind(binds[2][1], 2, binds[2][2])
  control.input:bind(binds[3][1], 3, binds[3][2])
  control.input:bind(binds[4][1], 4, binds[4][2])
  control.input:bind(binds[5][1], 5, binds[5][2])
  control.input:bind(binds[6][1], 6, binds[6][2])
  control.input:bind(binds[7][1], 7, binds[7][2])
  control.input:bind(binds[8][1], 8, binds[8][2])
  control.input:bind(binds[9][1], 9, binds[9][2])
  control.input:bind(binds[10][1], 10, binds[10][2])
  control.input:bind(binds[11][1], 11, binds[11][2])
end

function control.updateKeyboard()
  control.leftDown = control.input:down(3)
  control.leftPressed = control.input:pressed(3)
  control.rightDown = control.input:down(4)
  control.rightPressed = control.input:pressed(4)
  control.upDown = control.input:down(1)
  control.upPressed = control.input:pressed(1)
  control.downDown = control.input:down(2)
  control.downPressed = control.input:pressed(2)
  control.startDown = control.input:down(5)
  control.startPressed = control.input:pressed(5)
  control.selectDown = control.input:down(6)
  control.selectPressed = control.input:pressed(6)
  control.jumpDown = control.input:down(7)
  control.jumpPressed = control.input:pressed(7)
  control.shootDown = control.input:down(8)
  control.shootPressed = control.input:pressed(8)
  control.prevDown = control.input:down(9)
  control.prevPressed = control.input:pressed(9)
  control.nextDown = control.input:down(10)
  control.nextPressed = control.input:pressed(10)
  control.dashDown = control.input:down(11)
  control.dashPressed = control.input:pressed(11)
end

function control.flush()
  control.input:flush()
  touchInput.flush()
end