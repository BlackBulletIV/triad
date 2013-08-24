Floor = class("Floor", Entity)

function Floor:initialize(xml, width, height)
  Entity.initialize(self)
  self.layer = 7
  self.width = width
  self.height = height
  self.map = Tilemap:new(assets.images.tiles, 9, 9, width, height)
  self.map.usePositions = true
  self.color = { 150, 150, 150 }
  if xml then self:loadFromXML(xml) end
end

function Floor:loadFromXML(xml)
  local elem = findChild(xml, "floor")
  
  for _, v in ipairs(findChildren(elem, "tile")) do
    self.map:set(tonumber(v.attr.x), tonumber(v.attr.y), tonumber(v.attr.id) + 1)
  end
  
  for _, v in ipairs(findChildren(elem, "rect")) do
    self.map:setRect(
      tonumber(v.attr.x),
      tonumber(v.attr.y),
      tonumber(v.attr.w),
      tonumber(v.attr.h),
      tonumber(v.attr.id) + 1
    )
  end
end

function Floor:draw()
  love.graphics.setColor(self.color)
  self.map:draw(self.x, self.y)
end
