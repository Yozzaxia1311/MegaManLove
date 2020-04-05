local cartographer = {
  _VERSION = 'Cartographer',
  _DESCRIPTION = 'Simple Tiled map loading for LÖVE.',
  _URL = 'https://github.com/tesselode/cartographer',
  _LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

-- splits a path into directory, file (with filename), and just filename
-- i really only need the directory
-- https://stackoverflow.com/a/12191225
local function splitPath(path)
  return string.match(path, '(.-)([^\\/]-%.?([^%.\\/]*))$')
end

-- joins two paths together into a reasonable path that Lua can use.
-- handles going up a directory using ..
-- https://github.com/karai17/Simple-Tiled-Implementation/blob/master/sti/utils.lua#L5
local function formatPath(path)
  local npGen1, npGen2 = '[^SEP]+SEP%.%.SEP?', 'SEP+%.?SEP'
  local npPat1, npPat2 = npGen1:gsub('SEP', '/'), npGen2:gsub('SEP', '/')
  local k
  repeat path, k = path:gsub(npPat2, '/') until k == 0
  repeat path, k = path:gsub(npPat1, '') until k == 0
  if path == '' then path = '.' end
  return path
end

-- Decompress tile layer data
-- https://github.com/karai17/Simple-Tiled-Implementation/blob/master/sti/utils.lua#L67
local function getDecompressedData(data)
  local ffi = require("ffi")
  local d = {}
  local decoded = ffi.cast("uint32_t*", data)
  
  for i = 0, (data:len() / ffi.sizeof("uint32_t")) - 1 do
    table.insert(d, tonumber(decoded[i]))
  end
  
  return d
end

-- given a grid with w items per row, return the column and row of the nth item
-- (going from left to right, top to bottom)
-- https://stackoverflow.com/a/9816217
local function indexToCoordinates(n, w)
  return (n - 1) % w, math.floor((n - 1) / w)
end

local function coordinatesToIndex(x, y, w)
  return x + w * y + 1
end

local getByNameMetatable = {
  __index = function(self, key)
    for _, item in ipairs(self) do
      if item.name == key then return item end
    end
    return rawget(self, key)
  end,
}

local function getLayer(self, ...)
  local numberOfArguments = select('#', ...)
  if numberOfArguments == 0 then
    error('must specify at least one layer name', 2)
  end
  local layer
  local layerName = select(1, ...)
  if not self.layers[layerName] then return end
  layer = self.layers[layerName]
  for i = 2, numberOfArguments do
    layerName = select(i, ...)
    if not (layer.layers and layer.layers[layerName]) then return end
    layer = layer.layers[layerName]
  end
  return layer
end

local Layer = {}

-- A common class for all layer types.
Layer.base = {}
Layer.base.__index = Layer.base

function Layer.base:_init(map)
  self._map = map
end

-- Converts grid coordinates to pixel coordinates for this layer.
function Layer.base:gridToPixel(x, y)
  x, y = x * self._map.tilewidth, y * self._map.tileheight
  x, y = x + self.offsetx, y + self.offsety
  return x, y
end

-- Converts pixel coordinates for this layer to grid coordinates.
function Layer.base:pixelToGrid(x, y)
  x, y = x - self.offsetx, y - self.offsety
  x, y = x / self._map.tilewidth, y / self._map.tileheight
  x, y = math.floor(x), math.floor(y)
  return x, y
end

--[[
	Represents any layer type that can contain tiles
	(currently tile layers and object layers).
	There's no layer type in Tiled called "item layers",
	it's just a parent class to share code between
	tile layers and object layers.
]]
Layer.spritelayer = setmetatable({}, Layer.base)
Layer.spritelayer.__index = Layer.spritelayer

function Layer.spritelayer:_initAnimations()
  self._animations = {}
  for _, tileset in ipairs(self._map.tilesets) do
    for _, tile in ipairs(tileset.tiles) do
      if tile.animation then
        local gid = tileset.firstgid + tile.id
        self._animations[gid] = {
          tileset = tileset,
          frames = tile.animation,
          currentFrame = 1,
          timer = tile.animation[1].duration,
        }
      end
    end
  end
end

function Layer.spritelayer:_setSprite(x, y, gid, offGrid)
  -- if the gid is 0 (empty), remove the sprite at (x, y)
  -- (if it exists)
  if offGrid then
    if gid == 0 then
      if self._sprites.offGridMap[y] and self._sprites.offGridMap[y][x] then
        self._sprites.offGridMap[y][x] = nil
      end
      if self._sprites.offGridQuads[y] and self._sprites.offGridQuads[y][x] then
        self._sprites.offGridQuads[y][x] = nil
      end
    end
    
    if not self._sprites.offGridMap[y] then
      self._sprites.offGridMap[y] = {}
    end
    self._sprites.offGridMap[y][x] = gid
    
    local tileset = self._map:getTileset(gid)
    
    if tileset.image then
      -- get the new quad
      local animation = self._animations[gid]
      local quad = self._map:_getTileQuad(gid, animation and animation.currentFrame)
      -- if the sprite doesn't have a quad, add one
      if not self._sprites.offGridQuads[y] then
        self._sprites.offGridQuads[y] = {}
      end
      self._sprites.offGridQuads[y][x] = quad
      --otherwise, if there's no image, remove any quad that may be there
    elseif self._sprites.offGridQuads[y] and self._sprites.offGridQuads[y][x] then
      self._sprites.offGridQuads[y][x] = nil
    end
  else
    if gid == 0 then
      if self._sprites.map[y] and self._sprites.map[y][x] then
        self._sprites.map[y][x] = nil
      end
      if self._sprites.quads[y] and self._sprites.quads[y][x] then
        self._sprites.quads[y][x] = nil
      end
      return
    end
    
    if not self._sprites.map[y] then
      self._sprites.map[y] = {}
    end
    self._sprites.map[y][x] = gid
    -- update the sprite's tile GID
    local tileset = self._map:getTileset(gid)
    -- if the sprite should have a quad...
    if tileset.image then
      -- get the new quad
      local animation = self._animations[gid]
      local quad = self._map:_getTileQuad(gid, animation and animation.currentFrame)
      -- if the sprite doesn't have a quad, add one
      if not self._sprites.quads[y] then
        self._sprites.quads[y] = {}
      end
      self._sprites.quads[y][x] = quad
      --otherwise, if there's no image, remove any quad that may be there
    elseif self._sprites.quads[y] and self._sprites.quads[y][x] then
      self._sprites.quads[y][x] = nil
    end
  end
end

function Layer.spritelayer:_init(map)
  Layer.base._init(self, map)
  self:_initAnimations()
  self._sprites = {
    map = {},
    quads = {},
    offGridMap = {},
    offGridQuads = {},
    drawRange = {x=0, y=0, w=self._map.width*self._map.tilewidth, h=self._map.height*self._map.tileheight}
  }
end

function Layer.spritelayer:setDrawRange(x, y, w, h)
  local update = self._sprites.drawRange.x ~= x or self._sprites.drawRange.y ~= y or self._sprites.drawRange.w ~= w or self._sprites.drawRange.h ~= h
  
  self._sprites.drawRange.x = x or self._sprites.drawRange.x
  self._sprites.drawRange.y = y or self._sprites.drawRange.y
  self._sprites.drawRange.w = w or self._sprites.drawRange.w
  self._sprites.drawRange.h = h or self._sprites.drawRange.h
  
  if update then
    local ty = math.ceil(self._sprites.drawRange.y/self._map.tileheight)-1
    local th = math.floor(self._sprites.drawRange.h/self._map.tileheight)+1
    local tx = math.ceil(self._sprites.drawRange.x/self._map.tilewidth)-1
    local tw = math.floor(self._sprites.drawRange.w/self._map.tilewidth)+1
    for gid, animation in pairs(self._animations) do
      local tileset = self._map:getTileset(gid)
      if tileset.image then
        if #self._sprites.offGridQuads ~= 0 then
          for y, ytable in pairs(self._sprites.offGridQuads) do
            for x, _ in pairs(ytable) do
              if self._sprites.offGridMap[y] and self._sprites.offGridMap[y][x] then
                local quad = self._map:_getTileQuad(self._sprites.offGridMap[y][x], animation.currentFrame)
                self._sprites.offGridQuads[y][x] = quad
              end
            end
          end
        end
        for y=ty, ty+th do
          for x=tx, tx+tw do
            if self._sprites.map[y] and self._sprites.map[y][x] == gid and self._sprites.quads[y] and self._sprites.quads[y][x] then
              local quad = self._map:_getTileQuad(gid, animation.currentFrame)
              self._sprites.quads[y][x] = quad
            end
          end
        end
      end
    end
  end
end

function Layer.spritelayer:_updateAnimations(dt)
  local ty = math.ceil(self._sprites.drawRange.y/self._map.tileheight)-1
  local th = math.floor(self._sprites.drawRange.h/self._map.tileheight)+1
  local tx = math.ceil(self._sprites.drawRange.x/self._map.tilewidth)-1
  local tw = math.floor(self._sprites.drawRange.w/self._map.tilewidth)+1
  for gid, animation in pairs(self._animations) do
    -- decrement the animation timer
    animation.timer = animation.timer - 1000 * dt
    while animation.timer <= 0 do
      -- move to the next frame of animation
      animation.currentFrame = animation.currentFrame + 1
      if animation.currentFrame > #animation.frames then
        animation.currentFrame = 1
      end
      -- increment the animation timer by the duration of the new frame
      animation.timer = animation.timer + animation.frames[animation.currentFrame].duration
      -- update sprites
      local tileset = self._map:getTileset(gid)
      if tileset.image then
        if #self._sprites.offGridQuads ~= 0 then
          for y, ytable in pairs(self._sprites.offGridQuads) do
            for x, _ in pairs(ytable) do
              if self._sprites.offGridMap[y] and self._sprites.offGridMap[y][x] then
                local quad = self._map:_getTileQuad(self._sprites.offGridMap[y][x], animation.currentFrame)
                self._sprites.offGridQuads[y][x] = quad
              end
            end
          end
        end
        for y=ty, ty+th do
          for x=tx, tx+tw do
            if self._sprites.map[y] and self._sprites.map[y][x] == gid and self._sprites.quads[y] and self._sprites.quads[y][x] then
              local quad = self._map:_getTileQuad(gid, animation.currentFrame)
              self._sprites.quads[y][x] = quad
            end
          end
        end
      end
    end
  end
end

function Layer.spritelayer:update(dt)
  self:_updateAnimations(dt)
end

function Layer.spritelayer:draw()
  if not self.visible then return end
  love.graphics.push()
  love.graphics.translate(self.offsetx, self.offsety)
  -- draw the tiles within the draw range
  local ty = math.ceil(self._sprites.drawRange.y/self._map.tileheight)-1
  local th = math.floor(self._sprites.drawRange.h/self._map.tileheight)+1
  local tx = math.ceil(self._sprites.drawRange.x/self._map.tilewidth)-1
  local tw = math.floor(self._sprites.drawRange.w/self._map.tilewidth)+1
  
  for y=ty, ty+th do
    for x=tx, tx+tw do
      if self._sprites.map[y] and self._sprites.map[y][x] and self._sprites.quads[y] and self._sprites.quads[y][x] then
        local tileset = self._map:getTileset(self._sprites.map[y][x])
        if tileset.image then
          love.graphics.draw(self._map._images[tileset.image], self._sprites.quads[y][x], x*self._map.tilewidth, y*self._map.tileheight)
        end
      end
    end
  end
  love.graphics.pop()
end

-- Represents a tile layer in an exported Tiled map.
Layer.tilelayer = setmetatable({}, Layer.spritelayer)
Layer.tilelayer.__index = Layer.tilelayer

function Layer.tilelayer:_init(map)
  Layer.spritelayer._init(self, map)
  if self.encoding == "base64" then
    assert(require "ffi", "Compressed maps require LuaJIT FFI.\nPlease Switch your interperator to LuaJIT or your Tile Layer Format to \"CSV\".")
    if self.chunks then
      for k, v in ipairs(self.chunks) do
        if v.data then
          local data = love.data.decode("string", "base64", v.data)
          if self.compression == "zstd" then
            error("Zstandard is not a supported compression type.")
          elseif self.compression == "gzip" then
            data = love.data.decompress("string", "gzip", data)
          elseif self.compression == "zlib" then
            data = love.data.decompress("string", "zlib", data)
          end
          v.data = getDecompressedData(data)
        end
      end
    else
      local data = love.data.decode("string", "base64", self.data)
      if self.compression == "zstd" then
        error("Zstandard is not a supported compression type.")
      elseif self.compression == "gzip" then
        data = love.data.decompress("string", "gzip", data)
      elseif self.compression == "zlib" then
        data = love.data.decompress("string", "zlib", data)
      end
      self.data = getDecompressedData(data)
    end
  end
  for _, gid, gridX, gridY, _, _ in self:getTiles() do
    self:_setSprite(gridX, gridY, gid)
  end
end

-- Gets the left, top, right, and bottom bounds of the layer (in tiles).
function Layer.tilelayer:getGridBounds()
  if self.chunks then
    local left, top, right, bottom
    for _, chunk in ipairs(self.chunks) do
      local chunkLeft = chunk.x
      local chunkTop = chunk.y
      local chunkRight = chunk.x + chunk.width - 1
      local chunkBottom = chunk.y + chunk.height - 1
      if not left or chunkLeft < left then left = chunkLeft end
      if not top or chunkTop < top then top = chunkTop end
      if not right or chunkRight > right then right = chunkRight end
      if not bottom or chunkBottom > bottom then bottom = chunkBottom end
    end
    return left, top, right, bottom
  end
  return self.x, self.y, self.x + self.width - 1, self.y + self.height - 1
end

-- Gets the left, top, right, and bottom bounds of the layer (in pixels).
function Layer.tilelayer:getPixelBounds()
  local left, top, right, bottom = self:getGridBounds()
  left, top = self:gridToPixel(left, top)
  right, bottom = self:gridToPixel(right, bottom)
  return left, top, right, bottom
end

-- Returns the global ID of the tile at the given grid position,
-- or false if the tile is empty.
function Layer.tilelayer:getTileAtGridPosition(x, y)
  local gid
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      local pointInChunk = x >= chunk.x
      and x < chunk.x + chunk.width
      and y >= chunk.y
      and y < chunk.y + chunk.height
      if pointInChunk then
        gid = chunk.data[coordinatesToIndex(x - chunk.x, y - chunk.y, chunk.width)]
      end
    end
  else
    gid = self.data[coordinatesToIndex(x, y, self.width)]
  end
  gid = gid - 1
  if gid == -1 then return false end
  return gid
end

-- Sets the tile at the given grid position to the specified global ID.
function Layer.tilelayer:setTileAtGridPosition(x, y, id, tileset)
  local gid = self._map.tilesets[tileset or 1].firstgid + id
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      local pointInChunk = x >= chunk.x
      and x < chunk.x + chunk.width
      and y >= chunk.y
      and y < chunk.y + chunk.height
      if pointInChunk then
        local index = coordinatesToIndex(x - chunk.x, y - chunk.y, chunk.width)
        chunk.data[index] = gid
      end
    end
  else
    self.data[coordinatesToIndex(x, y, self.width)] = gid
  end
  self:_setSprite(x, y, gid)
end

-- Returns the global ID of the tile at the given pixel position,
-- or false if the tile is empty.
function Layer.tilelayer:getTileAtPixelPosition(x, y)
  return self:getTileAtGridPosition(self:pixelToGrid(x, y))
end

-- Sets the tile at the given pixel position to the specified global ID.
function Layer.tilelayer:setTileAtPixelPosition(pixelX, pixelY, id, tileset)
  local gridX, gridY = self:pixelToGrid(pixelX, pixelY)
  return self:setTileAtGridPosition(gridX, gridY, id, tileset)
end

function Layer.tilelayer:_getTileAtIndex(index)
  -- for infinite maps, treat all the chunk data like one big array
  if self.chunks then
    for _, chunk in ipairs(self.chunks) do
      if index <= #chunk.data then
        local gid = chunk.data[index]
        local gridX, gridY = indexToCoordinates(index, chunk.width)
        gridX, gridY = gridX + chunk.x, gridY + chunk.y
        local pixelX, pixelY = self:gridToPixel(gridX, gridY)
        return gid, gridX, gridY, pixelX, pixelY
      else
        index = index - #chunk.data
      end
    end
  elseif self.data[index] then
    local gid = self.data[index]
    local gridX, gridY = indexToCoordinates(index, self.width)
    local pixelX, pixelY = self:gridToPixel(gridX, gridY)
    return gid, gridX, gridY, pixelX, pixelY
  end
end

function Layer.tilelayer:_tileIterator(i)
  while true do
    i = i + 1
    local gid, gridX, gridY, pixelX, pixelY = self:_getTileAtIndex(i)
    if not gid then break end
    if gid ~= 0 then return i, gid, gridX, gridY, pixelX, pixelY end
  end
end

function Layer.tilelayer:getTiles()
  return self._tileIterator, self, 0
end

-- Represents an object layer in an exported Tiled map.
Layer.objectgroup = setmetatable({}, Layer.spritelayer)
Layer.objectgroup.__index = Layer.objectgroup

function Layer.objectgroup:_init(map)
  Layer.spritelayer._init(self, map)
  for _, object in ipairs(self.objects) do
    if object.gid and object.visible then
      self:_setSprite(object.x, object.y - object.height, object.gid, true)
    end
  end
end

-- Represents an image layer in an exported Tiled map.
Layer.imagelayer = setmetatable({}, Layer.base)
Layer.imagelayer.__index = Layer.imagelayer

function Layer.imagelayer:draw()
  if self.visible then
    love.graphics.draw(self._map._images[self.image], self.offsetx, self.offsety)
  end
end

-- Represents a layer group in an exported Tiled map.
Layer.group = setmetatable({}, Layer.base)
Layer.group.__index = Layer.group

function Layer.group:_init(map)
  Layer.base._init(self, map)
  for _, layer in ipairs(self.layers) do
    setmetatable(layer, Layer[layer.type])
    layer:_init(map)
  end
  setmetatable(self.layers, getByNameMetatable)
end

Layer.group.getLayer = getLayer

function Layer.group:update(dt)
  for _, layer in ipairs(self.layers) do
    if layer.update then layer:update(dt) end
  end
end

function Layer.group:setDrawRange(x, y, w, h)
  for _, layer in ipairs(self.layers) do
    if layer.setDrawRange then layer:setDrawRange(x, y, w, h) end
  end
end

function Layer.group:draw()
  if self.visible then
    for _, layer in ipairs(self.layers) do
      if layer.draw then layer:draw() end
    end
  end
end

local Map = {}
Map.__index = Map

-- Loads an image if it hasn't already been loaded yet.
-- Images are stored in map._images, and the key is the relative
-- path to the image.
function Map:_loadImage(relativeImagePath)
  if self._images[relativeImagePath] then return end
  local imagePath = formatPath(self.dir .. relativeImagePath)
  self._images[relativeImagePath] = love.graphics.newImage(imagePath)
end

-- Loads all of the images used by the map.
function Map:_loadImages()
  self._images = {}
  for _, tileset in ipairs(self.tilesets) do
    if tileset.image then self:_loadImage(tileset.image) end
    for _, tile in ipairs(tileset.tiles) do
      if tile.image then self:_loadImage(tile.image) end
    end
  end
  
  local function recursiveImageLayer(l)
      for _, layer in ipairs(l) do
        if layer.type == 'imagelayer' then
          self:_loadImage(layer.image)
        elseif layer.type == 'group' then
          recursiveImageLayer(layer.layers)
        end
      end
    end
  recursiveImageLayer(self.layers)
end

function Map:_initLayers()
  for _, layer in ipairs(self.layers) do
    setmetatable(layer, Layer[layer.type])
    layer:_init(self)
  end
  setmetatable(self.layers, getByNameMetatable)
end

function Map:_init(path)
  self.dir = splitPath(path)
  self.quadCache = {}
  self.tilesetCache = {}
  self.tileCache = {}
  self:_loadImages()
  setmetatable(self.tilesets, getByNameMetatable)
  self:_initLayers()
end

-- Gets the quad of the tile with the given global ID.
-- Returns false if the tileset is an image collection.
function Map:_getTileQuad(gid, frame)
  frame = frame or 1
  local tileset = self:getTileset(gid)
  if not tileset.image then return false end
  local id = gid - tileset.firstgid
  local tile = self:getTile(gid)
  if tile and tile.animation then
    id = tile.animation[frame].tileid
  end
  local image = self._images[tileset.image]
  local gridWidth = math.floor(image:getWidth() / (tileset.tilewidth + tileset.spacing))
  local x, y = indexToCoordinates(id + 1, gridWidth)
  id = id + tileset.firstgid
  if not self.quadCache[id] then
    self.quadCache[id] = love.graphics.newQuad(
      x * (tileset.tilewidth + tileset.spacing),
      y * (tileset.tileheight + tileset.spacing),
      tileset.tilewidth, tileset.tileheight,
      image:getWidth(), image:getHeight()
    )
  end
  return self.quadCache[id]
end

-- Gets the quad of the tile with the given global ID.
-- Returns false if the tileset uses a single image.
function Map:_getTileImage(gid, frame)
  frame = frame or 1
  local tileset = self:getTileset(gid)
  if tileset.image then return false end
  local tile = self:getTile(gid)
  if tile and tile.animation then
    tile = self:getTile(tileset.firstgid + tile.animation[frame].tileid)
  end
  return self._images[tile.image]
end

-- Gets the tileset that has the tile with the given global ID.
function Map:getTileset(gid)
  if self.tilesetCache[gid] then return self.tilesetCache[gid] end
  for i = #self.tilesets, 1, -1 do
    local tileset = self.tilesets[i]
    if tileset.firstgid <= gid then
      self.tilesetCache[gid] = tileset
      return tileset
    end
  end
end

-- Gets the data table for the tile with the given global ID, if it exists.
function Map:getTile(gid)
  if self.tileCache[gid] then return self.tileCache[gid] end
  local tileset = self:getTileset(gid)
  for _, tile in ipairs(tileset.tiles) do
    if tileset.firstgid + tile.id == gid then
      self.tileCache[gid] = tile
      return tile
    end
  end
end

-- Gets the type of the tile with the given global ID, if it exists.
function Map:getTileType(gid)
  local tile = self:getTile(gid)
  if not tile then return end
  return tile.type
end

-- Gets the value of the specified property on the tile
-- with the given global ID, if it exists.
function Map:getTileProperty(gid, propertyName)
  local tile = self:getTile(gid)
  if not tile then return end
  if not tile.properties then return end
  return tile.properties[propertyName]
end

-- Sets the value of the specified property on the tile
-- with the given global ID.
function Map:setTileProperty(gid, propertyName, propertyValue)
  local tile = self:getTile(gid)
  if not tile then
    local tileset = self:getTileset(gid)
    tile = {id = gid - tileset.firstgid}
    table.insert(tileset.tiles, tile)
  end
  tile.properties = tile.properties or {}
  tile.properties[propertyName] = propertyValue
end

Map.getLayer = getLayer

function Map:update(dt)
  for _, layer in ipairs(self.layers) do
    if layer.update then layer:update(dt) end
  end
end

function Map:drawBackground()
  if self.backgroundcolor then
    love.graphics.push()
    love.graphics.origin()
    local r = self.backgroundcolor[1] / 255
    local g = self.backgroundcolor[2] / 255
    local b = self.backgroundcolor[3] / 255
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", 0, 0,
      love.graphics.getCanvas():getDimensions())
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function Map:setDrawRange(x, y, w, h)
  for _, layer in ipairs(self.layers) do
    if layer.setDrawRange then layer:setDrawRange(x, y, w, h) end
  end
end

function Map:draw()
  self:drawBackground()
	love.graphics.setColor(1, 1, 1, 1)
  for _, layer in ipairs(self.layers) do
    if layer.draw then layer:draw() end
  end
end

local function finalXML2LuaTable(str, f)
  str = string.gsub(str, "<layer", "<layer type=\"tilelayer\"")
  str = string.gsub(str, "<objectgroup", "<layer type=\"objectgroup\"")
  str = string.gsub(str, "<imagelayer", "<layer type=\"imagelayer\"")
  str = string.gsub(str, "<group", "<layer type=\"group\"")
  str = string.gsub(str, "</objectgroup", "</layer")
  str = string.gsub(str, "</imagelayer", "</layer")
  str = string.gsub(str, "</group", "</layer")
  
  local result = xml2lua:parse(str).map
  
  local tmp = string.split(f, "/")
  tmp = tmp[#tmp]:len()
  local path = f:sub(0, -tmp-1)
  
  result.compressionLevel = nil
  result.height = tonumber(result.height)
  result.width = tonumber(result.width)
  result.editorsettings = nil
  result.nextlayerid = tonumber(result.nextlayerid)
  result.nextobjectid = tonumber(result.nextobjectid)
  result.luaversion = "5.1"
  result.tileheight = tonumber(result.tileheight)
  result.tilewidth = tonumber(result.tilewidth)
  local inf = result.infinite ~= "0"
  if result.backgroundcolor then
    result.backgroundcolor = result.backgroundcolor:gsub("#","")
    result.backgroundcolor = {tonumber("0x"..result.backgroundcolor:sub(1,2)),
      tonumber("0x"..result.backgroundcolor:sub(3,4)), tonumber("0x"..result.backgroundcolor:sub(5,6))}
  end

  if result.tileset then
    if not (type(result.tileset[1]) == "table" and type(result.tileset[2]) == "table") then
      result.tileset = {result.tileset}
    end
    result.tilesets = result.tileset
    result.tileset = nil
    
    for k, v in pairs(result.tilesets) do
      v.firstgid = tonumber(v.firstgid)
      local ts
      if v.source then
        if not love.filesystem.getInfo(path .. v.source) then
          error("No such tileset '" .. v.source .. "'")
        end
        
        ts = xml2lua:parse(love.filesystem.read(path .. v.source)).tileset
      else
        ts = v
      end
      
      if not v.source then
        ts.filename = v.source
      end
      ts.columns = tonumber(ts.columns)
      ts.tilecount = tonumber(ts.tilecount)
      ts.tilewidth = tonumber(ts.tilewidth)
      ts.tileheight = tonumber(ts.tileheight)
      ts.spacing = tonumber(ts.spacing) or 0
      ts.margin = tonumber(ts.margin) or 0
      
      if ts.grid then
        ts.grid.width = tonumber(ts.grid.width)
        ts.grid.height = tonumber(ts.grid.height)
      else
        ts.grid = {width=ts.tilewidth, height=ts.tileheight, orientation="orthogonal"}
      end
      
      if ts.tileoffset then
        ts.tileoffset.x = tonumber(ts.tileoffset.x)
        ts.tileoffset.y = tonumber(ts.tileoffset.y)
      else
        ts.tileoffset = {x=0, y=0}
      end
      
      if ts.image then
        if v.source then
          tmp = ts.image
          local tmp2 = string.split(v.source, "/")
          ts.image = v.source:sub(0, -tmp2[#tmp2]:len()-1) .. tmp.source
          ts.imagewidth = tonumber(tmp.width)
          ts.imageheight = tonumber(tmp.height)
        else
          v.imagewidth = tonumber(v.image.width)
          v.imageheight = tonumber(v.image.height)
          v.image = v.image.source
        end
      end
            
      ts.properties = ts.properties or {}
      local ref = ts.properties
      ts.properties = {}
      
      if ref.property then
        if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
          ref.property = {ref.property}
        end
        
        for o, p in pairs(ref.property) do
          if p.type == "int" or p.type == "float" then
            ts.properties[p.name] = tonumber(p.value)
          elseif p.type == "bool" then
            ts.properties[p.name] = p.value == "true"
          else
            ts.properties[p.name] = p.value
          end
        end
      end
      
      ts.terraintypes = ts.terraintypes or {}
      ref = ts.terraintypes
      ts.terraintypes = nil
      ts.terrains = {}
      if ref.terrain then
        if not (type(ref.terrain[1]) == "table" and type(ref.terrain[2]) == "table") then
          ref.terrain = {ref.terrain}
        end
        
        for o, p in pairs(ref.terrain) do
          p.tile = tonumber(p.tile)
          
          p.properties = p.properties or {}
          local ref2 = p.properties
          p.properties = {}
          if ref2.property then
            if not (type(ref2.property[1]) == "table" and type(ref2.property[2]) == "table") then
              ref2.property = {ref2.property}
            end
            
            for o2, p2 in pairs(ref2.property) do
              if p2.type == "int" or p2.type == "float" then
                p.properties[p2.name] = tonumber(p2.value)
              elseif p2.type == "bool" then
                p.properties[p2.name] = p2.value == "true"
              else
                p.properties[p2.name] = p2.value
              end
            end
          end
          
          ts.terrains[#ts.terrains+1] = p
        end
      end
      
      if ts.tile then
        ts.tiles = ts.tile
        ts.tile = nil
        if not (type(ts.tiles[1]) == "table" and type(ts.tiles[2]) == "table") then
          ts.tiles = {ts.tiles}
        end
        
        for o, p in pairs(ts.tiles) do
          p.id = tonumber(p.id)
          p.probability = tonumber(p.probability)
          
          if p.properties then
            if not (type(p.properties.property[1]) == "table" and type(p.properties.property[2]) == "table") then
              p.properties.property = {p.properties.property}
            end
            
            local ref = p.properties.property
            p.properties = {}
            
            for o2, p2 in pairs(ref) do
              if p2.type == "int" or p2.type == "float" then
                p.properties[p2.name] = tonumber(p2.value)
              elseif p2.type == "bool" then
                p.properties[p2.name] = p2.value == "true"
              else
                p.properties[p2.name] = p2.value
              end
            end
          end
          
          if p.terrain then
            p.terrain = string.split(p.terrain, ",")
            for o2, p2 in pairs(p.terrain) do
              p.terrain[o2] = tonumber(p.terrain[o2]) or -1
            end
          end
          
          if p.animation then
            if not (type(p.animation.frame[1]) == "table" and type(p.animation.frame[2]) == "table") then
              p.animation.frame = {p.animation.frame}
            end
            
            for o2, p2 in pairs(p.animation.frame) do
              p2.duration = tonumber(p2.duration)
              p2.tileid = tonumber(p2.tileid)
            end
            
            p.animation = p.animation.frame
            p.animation.frame = nil
          end
          
        end
      else
        ts.tiles = {}
      end
      
      ts.firstgid = v.firstgid
      ts.version = nil
      ts.tiledversion = nil
      
      result.tilesets[k] = ts
    end
  end
  local function layerGroupParenting(tab)
    if tab.layer then
      if not (type(tab.layer[1]) == "table" and type(tab.layer[2]) == "table") then
        tab.layer = {tab.layer}
      end
      for k, v in pairs(tab.layer) do
        if v.type == "tilelayer" then
          v.x = tonumber(v.x) or 0
          v.y = tonumber(v.y) or 0
          v.visible = v.visible ~= "0"
          v.opacity = tonumber(v.opacity) or 1
          v.offsetx = tonumber(v.offsetx) or 0
          v.offsety = tonumber(v.offsety) or 0
          v.width = tonumber(v.width) or 0
          v.height = tonumber(v.height) or 0
          v.id = tonumber(v.id)
          
          if v.data then
            if v.data.encoding then
              v.encoding = v.data.encoding
              v.data.encoding = nil
            end
            if v.data.compression then
              v.compression = v.data.compression
              v.data.compression = nil
            end
            
            if inf then
              if v.data.chunk then
                if not (type(v.data.chunk[1]) == "table" and type(v.data.chunk[2]) == "table") then
                  v.data.chunk = {v.data.chunk}
                end
                v.chunks = v.data.chunk

                for i, j in pairs(v.chunks) do
                  j.data = j[1]
                  j[1] = nil
                end

                v.data = nil

                for i, j in pairs(v.chunks) do
                  j.width = tonumber(j.width)
                  j.height = tonumber(j.height)
                  j.x = tonumber(j.x)
                  j.y = tonumber(j.y)
                end

                if v.encoding  == "csv" then
                  for i, j in pairs(v.chunks) do
                    local full = string.split(j.data, "\r\n")
                    j.data = ""
                    for o, p in ipairs(full) do
                      j.data = j.data .. p
                    end
                    j.data = string.split(j.data, ",")
                    for o, p in ipairs(j.data) do
                      j.data[o] = tonumber(p)
                    end
                  end
                end
              else
                v.data = nil
                v.chunks = {}
              end
            else
              if v.encoding == "csv" then
                local full = string.split(v.data[1], "\r\n")
                v.data[1] = ""
                for i, j in ipairs(full) do
                  v.data[1] = v.data[1] .. j
                end
              end
              v.data = v.data[1]
              if v.encoding == "csv" then
                v.data = string.split(v.data, ",")
                for i, j in ipairs(v.data) do
                  v.data[i] = tonumber(j)
                end
              end
            end
          end
        elseif v.type == "objectgroup" then
          v.id = tonumber(v.id)
          v.visible = v.visible ~= "0"
          v.opacity = tonumber(v.opacity) or 1
          v.offsetx = tonumber(v.offsetx) or 0
          v.offsety = tonumber(v.offsety) or 0
          v.draworder = v.draworder or "topdown"
          if v.object then
            if not (type(v.object[1]) == "table" and type(v.object[2]) == "table") then
              v.object = {v.object}
            end
            v.objects = v.object
            v.object = nil
            
            local function templateParenting(j, fcache)
              local tf = {}
              
              if j.template then
                if not fcache[path .. j.template] then
                  if not love.filesystem.getInfo(path .. j.template) then
                    error("No such template file '" .. j.template .. "'")
                  end
                  fcache[path .. j.template] = xml2lua:parse(love.filesystem.read(path .. j.template)).template.object
                end
                tf = templateParenting(table.clone(fcache[path .. j.template]), fcache)
              end
              
              j.type = j.type == nil and (tf.type == nil and "" or tf.type) or j.type
              j.name = j.name == nil and (tf.name == nil and "" or tf.name) or j.name
              j.width = tonumber(j.width) or tonumber(tf.width) or 0
              j.height = tonumber(j.height) or tonumber(tf.height) or 0
              j.x = tonumber(j.x) or tonumber(tf.x)
              j.y = tonumber(j.y) or tonumber(tf.y)
              j.rotation = tonumber(j.rotation) or tonumber(tf.rotation) or 0
              j.visible = j.visible == nil and (tf.visible ~= "0") or (j.visible ~= "0")
              j.id = tonumber(j.id) or tonumber(tf.id)
              
              if not j.point and not j.ellipse and not j.polyline and not j.polygon and not j.text then
                j.point = tf.tmpPoint
                j.ellipse = tf.tmpEllipse
                j.polyline = tf.tmpPolyline
                j.polygon = tf.tmpPolygon
                j.text = tf.tmpText
              end
              
              if j.point then
                j.tmpPoint = j.point
                j.point = nil
                j.shape = "point"
              elseif j.ellipse then
                j.tmpEllipse = j.ellipse
                j.ellipse = nil
                j.shape = "ellipse"
              elseif j.polyline then
                j.tmpPolyline = j.polyline
                j.shape = "polyline"
                
                j.polyline = string.split(j.polyline.points, " ")
                local ptmp = {}
                for o, p in pairs(j.polyline) do
                  ptmp[o] = string.split(p, ",")
                  for o2, p2 in pairs(ptmp[o]) do
                    ptmp[o][o2] = tonumber(p2)
                  end
                end
                j.polyline = ptmp          
              elseif j.polygon then
                j.tmpPolygon = j.polygon
                j.shape = "polygon"
                
                j.polygon = string.split(j.polygon.points, " ")
                local ptmp = {}
                for o, p in pairs(j.polygon) do
                  ptmp[o] = string.split(p, ",")
                  for o2, p2 in pairs(ptmp[o]) do
                    ptmp[o][o2] = tonumber(p2)
                  end
                end
                j.polygon = ptmp  
              elseif j.text then
                j.tmpText = j.text
                j.shape = "text"
                j.wrap = j.wrap ~= "0"
                j.text = j.text[1]
              else
                j.shape = "rectangle"
                j.gid = tonumber(j.gid) or tonumber(tf.gid)
              end
              
              j.properties = j.properties or {}
              local ref = j.properties
              j.properties = {}
              if ref.property then
                if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
                  ref.property = {ref.property}
                end
                
                for o, p in pairs(ref.property) do
                  if p.type == "int" or p.type == "float" then
                    j.properties[p.name] = tonumber(p.value)
                  elseif p.type == "bool" then
                    j.properties[p.name] = p.value == "true"
                  else
                    j.properties[p.name] = p.value
                  end
                end
              end
              
              if tf.properties then
                for o, p in pairs(tf.properties) do
                  if j.properties[o] == nil then
                    j.properties[o] = p
                  end
                end
              end
              
              return j
            end
            
            local tcache = {}
            for i, j in pairs(v.objects) do
              j = templateParenting(j, tcache)
            end
            for i, j in pairs(v.objects) do
              j.tmpPoint = nil
              j.tmpEllipse = nil
              j.tmpPolyline = nil
              j.tmpPolygon = nil
              j.tmpText = nil
            end
          else
            v.objects = {}
          end
        elseif v.type == "imagelayer" then
          v.id = tonumber(v.id)
          v.visible = v.visible ~= "0"
          v.opacity = tonumber(v.opacity) or 1
          v.offsetx = tonumber(v.offsetx) or 0
          v.offsety = tonumber(v.offsety) or 0
          v.image = v.image.source
        elseif v.type == "group" then
          v.id = tonumber(v.id)
          v.visible = v.visible ~= "0"
          v.opacity = tonumber(v.opacity) or 1
          v.offsetx = tonumber(v.offsetx) or 0
          v.offsety = tonumber(v.offsety) or 0
          
          layerGroupParenting(v)
        end
        
        v.properties = v.properties or {}
        local ref = v.properties
        v.properties = {}
        if ref.property then
          if not (type(ref.property[1]) == "table" and type(ref.property[2]) == "table") then
            ref.property = {ref.property}
          end
          
          for i, j in pairs(ref.property) do
            if j.type == "int" or j.type == "float" then
              v.properties[j.name] = tonumber(j.value)
            elseif j.type == "bool" then
              v.properties[j.name] = j.value == "true"
            else
              v.properties[j.name] = j.value
            end
          end
        end
      end
      tab.layers = tab.layer
      tab.layer = nil
    else
      tab.layers = {}
    end
  end
  
  layerGroupParenting(result)
  
  return result
end

-- Loads a Tiled map from a tmx file.
function cartographer.load(path)
  if not path then error('No map path provided', 2) end
  local map
  if path:sub(path:len()-3, path:len()) == ".tmx" then
    map = setmetatable(finalXML2LuaTable(love.filesystem.read(path), path), Map)
  else
    map = setmetatable(love.filesystem.load(path)(), Map)
  end
  map:_init(path)
  return map
end

return cartographer