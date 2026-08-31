terrains = {}

function onload()
  self.lock()
  self.interactable = false
end

function onCollisionEnter(a)
  if a.collision_object.tag == "Tile" then
    tile = a.collision_object
    terrains[tile.getGUID()] = tile
  end
end