record = {}

function record.ser()
  return {
      demo = record.demo,
      anyPressed = record.anyPressed,
      pressAnyway = record.pressAnyway,
      anyPressedDuringRec = record.anyPressedDuringRec,
      recPos = record.recPos,
      record = record.record,
      loadedRec = record.loadedRec,
      loadedRecPos = record.loadedRecPos,
      recordInput = record.recordInput,
      keyPressedRec = record.keyPressedRec,
      gamepadPressedRec = record.gamepadPressedRec,
      gamepadAxisRec = record.gamepadAxisRec,
      touchPressedRec = record.touchPressedRec,
      textInputRec = record.textInputRec,
      _openRecQ = record._openRecQ,
      _backupKey = record._backupKey
    }
end

function record.deser(t)
  record.demo = t.demo
  record.anyPressed = t.anyPressed
  record.pressAnyway = t.pressAnyway
  record.anyPressedDuringRec = t.anyPressedDuringRec
  record.recPos = t.recPos
  record.record = t.record
  record.recordInput = t.recordInput
  record.loadedRec = t.loadedRec
  record.loadedRecPos = t.loadedRecPos
  record.keyPressedRec = t.keyPressedRec
  record.gamepadPressedRec = t.gamepadPressedRec
  record.gamepadAxisRec = t.gamepadAxisRec
  record.touchPressedRec = t.touchPressedRec
  record.textInputRec = t.textInputRec
  record._openRecQ = t._openRecQ
  record._backupKey = t._backupKey
end

megautils.initEngineFuncs.record = {func=function()
    record.init()
  end, autoClean=false}

record._startRecQ = false
record._openRecQ = nil

function record.init()
  record.demo = false
  record.pressAnyway = false
  record.anyPressedDuringRec = false
  record.anyPressed = false
  record.record = {data = {}}
  record.recPos = 1
  record.loadedRec = {data = {}}
  record.loadedRecPos = 1
  record._backupKey = nil
end

function record.resetRec()
  record.recPos = 1
  record.record = {data = {}}
  record.anyPressed = false
  record.recordInput = false
  record.updateDemoFunc = nil
  record.drawDemoFunc = nil
  record._backupKey = nil
end

function record.startRecQ(f)
  record._startRecQ = f == nil or f
end

function record.startRec()
  record.resetRec()
  
  record.record.context = ser()
  record.recordInput = true
end

function record.finishRecord(name)
  record.record.last = record.recPos
  save.save(name, record.record)
  
  record.resetRec()
end

function record.resetLoadedRec()
  record.loadedRecPos = 1
  record.loadedRecord = {data = {}}
  record.anyPressed = false
  record.pressAnyway = false
  record.demo = false
end

function record.openRecQ(f)
  record._openRecQ = f
end

function record.openRec(f)
  record.resetLoadedRec()
  local file = save.load(f)
  record.oldContext = ser()
  
  deser(file.context)
  
  record.recPos = 1
  record.record = {data = {}}
  record.recordInput = false
  record.loadedRec = file
  record.demo = true
end

function record.update()
  if record.demo then
    record.playRecord()
    local result = false
    result = record.updateDemo()
    if record.loadedRecPos >= record.loadedRec.last then
      result = true
    end
    if result then
      record.resetLoadedRec()
      
      if record.returning then
        record.returning()
        record.returning = nil
      else
        deserQueue = function()
          record.demo = false
          local c = record.oldContext
          record.oldContext = nil
          return c
        end
      end
    end
    
    record._backUpKey = nil
  end
  if record.recordInput then
    record.doRecording()
  end
end

function record.playRecord()
  if record.loadedRec.data[record.loadedRecPos] then
    record.pressAnyway = true
    
    if record.loadedRec.data[record.loadedRecPos].kp then
      for i=1, #record.loadedRec.data[record.loadedRecPos].kp do
        love.keypressed(unpack(record.loadedRec.data[record.loadedRecPos].kp[i]))
      end
    end
    
    if record.loadedRec.data[record.loadedRecPos].gpp then
      for i=1, #record.loadedRec.data[record.loadedRecPos].gpp do
        love.gamepadpressed(unpack(record.loadedRec.data[record.loadedRecPos].gpp[i]))
      end
    end
    
    if record.loadedRec.data[record.loadedRecPos].gpa then
      for i=1, #record.loadedRec.data[record.loadedRecPos].gpa do
        love.keypressed(unpack(record.loadedRec.data[record.loadedRecPos].gpa[i]))
      end
    end
    
    if record.loadedRec.data[record.loadedRecPos].tp then
      for i=1, #record.loadedRec.data[record.loadedRecPos].tp do
        love.touchpressed(unpack(record.loadedRec.data[record.loadedRecPos].tp[i]))
      end
    end
    
    if record.loadedRec.data[record.loadedRecPos].ti then
      for i=1, #record.loadedRec.data[record.loadedRecPos].ti do
        love.textinput(record.loadedRec.data[record.loadedRecPos].ti[i])
      end
    end
    
    record.pressAnyway = false
  else
    
  end
  record.loadedRecPos = record.loadedRecPos + 1
end

function record.doRecording()
  for k, _ in pairs(input.keys) do
    if input.down[k] then
      if not record.record.data[record.recPos] then
        record.record.data[record.recPos] = {}
      end
      if not record.record.data[record.recPos].down then
        record.record.data[record.recPos].down = {}
      end
      record.record.data[record.recPos].down[k] = input.down[k]
    end
    if input.pressed[k] then
      if not record.record.data[record.recPos] then
        record.record.data[record.recPos] = {}
      end
      if not record.record.data[record.recPos].pressed then
        record.record.data[record.recPos].pressed = {}
      end
      record.record.data[record.recPos].pressed[k] = input.pressed[k]
    end
  end
  
  for k, _ in input.pairs(input.touchDown) do
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    if not record.record.data[record.recPos].touchDown then
      record.record.data[record.recPos].touchDown = {}
    end
    record.record.data[record.recPos].touchDown[k] = input.touchDown[k]
  end
  
  for k, _ in input.pairs(input.touchPressed) do
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    if not record.record.data[record.recPos].touchPressed then
      record.record.data[record.recPos].touchPressed = {}
    end
    record.record.data[record.recPos].touchPressed[k] = input.touchPressed[k]
  end
  
  if record.keyPressedRec then
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    record.record.data[record.recPos].kp = record.keyPressedRec
    record.keyPressedRec = nil
  end
  
  if record.gamepadPressedRec then
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    record.record.data[record.recPos].gpp = record.gamepadPressedRec
    record.gamepadPressedRec = nil
  end
  
  if record.gamepadAxisRec then
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    record.record.data[record.recPos].gpa = record.gamepadAxisRec
    record.gamepadAxisRec = nil
  end
  
  if record.touchPressedRec then
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    record.record.data[record.recPos].tp = record.touchPressedRec
    record.touchPressedRec = nil
  end
  
  if record.textInputRec then
    if not record.record.data[record.recPos] then
      record.record.data[record.recPos] = {}
    end
    record.record.data[record.recPos].ti = record.textInputRec
    record.textInputRec = nil
  end
  
  record.recPos = record.recPos + 1
  
  if record.updateDemo() then
    console.parse("recend")
    if console.state == 0 then
      console.open()
    end
  end
end

function record.updateDemo()
  if record.updateDemoFunc then
    return record.anyPressedDuringRec or record.updateDemoFunc()
  else
    if record.demo then
      return record.anyPressedDuringRec
    else
      return record._backupKey == "backspace"
    end
  end
end

function record.drawDemo()
  if record.drawDemoFunc then
    record.drawDemoFunc()
  else
    if record.demo then
      love.graphics.setColor(0, 0, 0, 0.4)
      love.graphics.rectangle("fill", view.w-144, view.h-24, 144, 16)
      love.graphics.setColor(1, 1, 1, 0.8)
      love.graphics.setFont(mmFont)
      love.graphics.print("REPLAY", view.w - 64, view.h - 24)
      love.graphics.print("ANY BUTTON TO END", view.w - 142, view.h - 16)
    elseif record.recordInput then
      love.graphics.setColor(0, 0, 0, 0.4)
      love.graphics.rectangle("fill", view.w-134, view.h-24, 142, 16)
      love.graphics.setColor(1, 1, 1, 0.8)
      love.graphics.setFont(mmFont)
      love.graphics.print("RECORDING", view.w - 88, view.h - 24)
      love.graphics.print("BACKSPACE TO END", view.w - 132, view.h - 16)
    end
  end
end