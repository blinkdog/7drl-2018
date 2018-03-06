# helper.coffee
# Copyright 2018 Patrick Meade
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------

NUM_LEVELS = 100

world = null

exports.addMessage = (msg) ->
  ents = world.find "messages"
  for ent in ents
    {log} = ent.messages
    log.push msg

exports.canDoorClose = (doorEnt) ->
  dx = doorEnt.position.x
  dy = doorEnt.position.y
  dz = doorEnt.position.z
  # check everything that might be positioned at the door
  ents = world.find "position"
  for ent in ents
    # the door won't stop itself from closing
    continue if ent is doorEnt
    # check if the thing is in the same position
    {x,y,z} = ent.position
    if (x is dx) and (y is dy) and (z is dz)
      # only an obstacle will stop the door from closing
      if ent.obstacle?
        return false
  # having checked all the entities, the door is allowed to close
  return true

exports.getCamera = ->
  ents = world.find "camera"
  for ent in ents
    return ent
  return null

exports.getGameMode = ->
  ents = world.find "gameMode"
  for ent in ents
    {gameMode} = ent
    return gameMode.mode
  return null

# TODO: Feels like there could be a better position/extents -> name
#       implementation using entity components, but I don't want to
#       rewrite it right now
exports.getNameAt = (pos) ->
  lx = pos.x
  ly = pos.y
  lz = pos.z
  # first look for objects
  ents = world.find "position"
  for ent in ents
    {x, y, z} = ent.position
    if (lx is x) and (ly is y) and (lz is z)
      if ent.door?
        if ent.door.open
          return "Door (Open)"
        else
          return "Door (Closed)"
      if ent.name?
        return ent.name.name
      else
        return "An object"
  # next look for corridors
  ents = world.find "corridor"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.area
    if (lx >= x1) and (lx <= x2) and (ly >= y1) and (ly <= y2) and (lz is z)
      return "Corridor"
  # next look for rooms
  ents = world.find "room"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.area
    if (lx >= x1) and (lx <= x2) and (ly >= y1) and (ly <= y2) and (lz is z)
      return "Room"
  # can't find anything at that location
  return "Nothing"

exports.haveDoorAt = (dx, dy, dz) ->
  ents = world.find [ "door", "position" ]
  for ent in ents
    {x,y,z} = ent.position
    if (x is dx) and (y is dy) and (z is dz)
      return true
  return false

exports.isWalkable = (wx, wy, wz) ->
  # see if anything is blocking
  ents = world.find [ "obstacle", "position" ]
  for ent in ents
    continue if ent.player? # the player doesn't block themselves
    {x,y,z} = ent.position
    if (x is wx) and (y is wy) and (z is wz)
      return
        ok: false
        ent: ent
  # next look for doors
  ents = world.find "door"
  for ent in ents
    {x,y,z} = ent.position
    {open} = ent.door
    if (x is wx) and (y is wy) and (z is wz)
      return
        ok: open
        ent: ent
  # next look for corridors
  ents = world.find "corridor"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.area
    if (wx >= x1) and (wx <= x2) and (wy >= y1) and (wy <= y2) and (wz is z)
      return
        ok: true
        ent: ent
  # next look for rooms
  ents = world.find "room"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.area
    if (wx >= x1) and (wx <= x2) and (wy >= y1) and (wy <= y2) and (wz is z)
      return
        ok: true
        ent: ent
  # nothing allows us to walk there
  return
    ok: false
    ent: null

exports.getMessages = ->
  ents = world.find "messages"
  for ent in ents
    return ent
  return null

exports.getNearestRoom = (x, y, z) ->
  nearestRoom = null
  minDist = 4294967295
  # for every room in the world
  ents = world.find ["area", "room"]
  for ent in ents
    {area} = ent
    # skip any rooms that aren't on the same level
    continue if area.z isnt z
    # determine the center of the room
    cx = Math.floor (area.x1+area.x2) / 2
    cy = Math.floor (area.y1+area.y2) / 2
    # determine the distance to the room
    dist = Math.sqrt (cx-x)*(cx-x) + (cy-y)*(cy-y)
    # if this room is closer than any we've found
    if dist < minDist
      minDist = dist
      nearestRoom = ent
  # return the room nearest to the provided coordinates
  return nearestRoom

exports.getPlayer = ->
  ents = world.find "player"
  for ent in ents
    return ent
  return null

exports.getRandomName = (x, y, z) ->
  {firstNames} = require "../data/firstNames"
  {lastNames} = require "../data/lastNames"
  return "#{firstNames.random()} #{lastNames.random()}"

exports.getTick = ->
  ents = world.find "gameClock"
  for ent in ents
    return ent.gameClock.moves

exports.order = (x1, y1, x2, y2) ->
  # NOTE: the map generator can provide unordered coordinates
  #       when generating corridors; this orders them
  minX = Math.min x1, x2
  maxX = Math.max x1, x2
  minY = Math.min y1, y2
  maxY = Math.max y1, y2
  return
    x1: minX
    y1: minY
    x2: maxX
    y2: maxY

exports.setCamera = (x, y, z) ->
  ents = world.find "camera"
  for ent in ents
    ent.camera.x = x
    ent.camera.y = y
    ent.camera.z = z

exports.setGameMode = (mode) ->
  ents = world.find "gameMode"
  for ent in ents
    {gameMode} = ent
    gameMode.mode = mode

exports.setWorld = (x) ->
  world = x

exports.tick = ->
  ents = world.find "gameClock"
  for ent in ents
    ent.gameClock.moves++

#----------------------------------------------------------------------
# end of helper.coffee
