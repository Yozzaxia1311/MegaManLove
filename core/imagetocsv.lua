local imageToCSV = {}

imageToCSV.tmp = {}

local function imgMap(x, y, r, g, b, a)
  imageToCSV.tmp[#imageToCSV.tmp+1] = (a > 0) and 1 or 0
  return r, g, b, a
end

function imageToCSV.output(path, out)
  local result
  local img = love.image.newImageData(path)
  
  imageToCSV.tmp = {}
  img:mapPixel(imgMap)
  
  result = tostring(img:getWidth()) .. "#"
  for i=1, #imageToCSV.tmp do
    result = result .. tostring(imageToCSV.tmp[i]) .. ((i == #imageToCSV.tmp) and "" or ",")
  end
  
  save.createDirChain(out)
  love.filesystem.write(out, result)
end

return imageToCSV