LevelPlanning = class("LevelPlanning", LevelBase)
LevelPlanning.static.levels = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }

function LevelPlanning:initialize(index, xml)
  if not xml then
    local xmlFile = love.filesystem.read("assets/levels/" .. LevelPlanning.levels[index] .. ".oel")
    xml = slaxml:dom(xmlFile).root
  end
  
  LevelBase.initialize(self, xml)
  self.index = index
  self.playerSelections = {}
  self.turrets = {}
  self:loadCommonObjects()
  
  local obj = findChild(self.xml, "objects")
  
  for _, v in ipairs(findChildren(obj, "player")) do
    local p = PlayerSelection:fromXML(v)
    self.playerSelections[#self.playerSelections + 1] = p
    self:add(p)
  end
  
  for _, v in ipairs(findChildren(obj, "turret")) do
    local t = Turret:fromXML(v)
    t.active = false
    self.turrets[#self.turrets + 1] = t
    self:add(t)
  end
end

function LevelPlanning:start()
  fade.fadeIn(0.5)
  
  for _, v in ipairs(self.playerSelections) do
    v.alpha = 0
    v:animate(0.25, { alpha = 255 }, ease.quadOut)
  end
end

function LevelPlanning:update(dt)
  LevelBase.update(self, dt)
  if input.pressed("restart") then self:restart() end
end

function LevelPlanning:draw()
  LevelBase.draw(self, dt)
  drawCrosshair()
end

function LevelPlanning:beginWave(selection)
  self.selection = selection
  local skipFade = true
  
  for _, v in ipairs(self.playerSelections) do
    if v ~= selection and not v.played then
      v:animate(0.25, { alpha = 0 }, ease.quadIn)
      skipFade = false
    end
  end
  
  if skipFade then
    ammo.world = LevelWave:new(self)
  else
    delay(0.25, function() ammo.world = LevelWave:new(self) end)
  end
end

function LevelPlanning:endWave(player)
  if self.restarting then return end
  ammo.world = self
  
  if not self.finalReplay and self.selection then
    local done = true
    self.allEnemiesKilled = true
    
    self.selection.played = true
    self.selection.inputLog = player.inputLog
    self.selection.posLog = player.posLog
    self.selection.deathTime = player.deathTime
    self.selection = nil
    
    for _, v in ipairs(self.turrets) do
      if not v.deathTime then self.allEnemiesKilled = false end
    end
    
    if not self.allEnemiesKilled then
      for _, v in ipairs(self.playerSelections) do
        if not v.played then done = false end
      end
    end
    
    if done then
      data.levelComplete(self.index)
      self.finalReplay = true
      ammo.world = LevelWave:new(self)
    end
  end
end

function LevelPlanning:restart()
  self.restarting = true
  fade.fadeOut(0.5, function() ammo.world = LevelPlanning:new(self.index, self.xml) end)
end

function LevelPlanning:nextLevel()
  if self.index == #LevelPlanning.levels then
    fade.fadeOut(0.5, function() ammo.world = MainMenu:new() end)
  else
    fade.fadeOut(0.5, function() ammo.world = LevelPlanning:new(self.index + 1) end)
  end
end
