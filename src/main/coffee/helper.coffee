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

{DISTANCE} = require("./config").STATION_SIZE
{OMNISCIENT} = require("./config").DEBUG

world = null

exports.addMessage = (msg) ->
  ents = world.find "messages"
  for ent in ents
    {log} = ent.messages
    log.push msg
  return true

exports.addMessageAt = (mx, my, mz, msg) ->
  player = exports.getPlayer()
  px = player.position.x
  py = player.position.y
  pz = player.position.z
  if exports.canCoordsSee px, py, pz, mx, my, mz
    return exports.addMessage msg
  if OMNISCIENT
    return exports.addMessage "(#{mx},#{my},#{mz}): #{msg}"
  return false

exports.areCoordsAdjacent = (sx, sy, sz, dx, dy, dz) ->
  ax = Math.abs sx-dx
  ay = Math.abs sy-dy
  az = Math.abs sz-dz
  return ((ax <= 1) and (ay <= 1) and (az is 0))

exports.areEntitiesAdjacent = (s, d) ->
  return exports.arePositionsAdjacent s.position, d.position

exports.arePositionsAdjacent = (s, d) ->
  return exports.areCoordsAdjacent s.x, s.y, s.z, d.x, d.y, d.z

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

exports.canCoordsSee = (sx, sy, sz, dx, dy, dz) ->
  # we can't see things on a diffrent floor
  return false if dz isnt sz
  # now we do fov calculations
  lightPasses = (x,y) ->
    walk = exports.isSeeable x, y, sz
    return walk.ok
  fov = new ROT.FOV.PreciseShadowcasting lightPasses
  seen = false
  fov.compute sx, sy, DISTANCE, (x, y, r, visibility) ->
    if (x is dx) and (y is dy)
      seen = true
  return seen

exports.canEntitiesSee = (s, d) ->
  return exports.canPositionsSee s.position, d.position

exports.canPositionsSee = (s, d) ->
  return exports.canCoordsSee s.x, s.y, s.z, d.x, d.y, d.z

exports.getCamera = ->
  ents = world.find "camera"
  for ent in ents
    return ent
  return null

exports.getEntsAt = (pos) ->
  found = []
  lx = pos.x
  ly = pos.y
  lz = pos.z
  # first look for positions
  ents = world.find "position"
  for ent in ents
    {x, y, z} = ent.position
    if (lx is x) and (ly is y) and (lz is z)
      found.push ent
  # next look for areas
  ents = world.find "area"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.area
    if (lx >= x1) and (lx <= x2) and (ly >= y1) and (ly <= y2) and (lz is z)
      found.push ent
  # return everything we found (if anything)
  found.sort lookTargetSort
  return found

exports.getGameMode = ->
  ents = world.find "gameMode"
  for ent in ents
    {gameMode} = ent
    return gameMode.mode
  return null

exports.getLiftOnLevel = (level, going) ->
  ents = world.find [ "lift", "position" ]
  for ent in ents
    {x,y,z} = ent.position
    {dir} = ent.lift
    if (dir is going) and (z is level)
      return ent
  return null

exports.getMessages = ->
  ents = world.find "messages"
  for ent in ents
    return ent
  return null

exports.getNameAt = (pos) ->
  ents = exports.getEntsAt pos
  if ents.length is 0
    return "Nothing"
  ent = ents[0]
  if ent.corridor
    return "Corridor"
  if ent.room
    return "Room"
  if ent.door?
    if ent.door.open
      return "Door (Open)"
    else
      return "Door (Closed)"
  if ent.position?
    if ent.name?
      return ent.name.name
    else
      return "An object"
  return "Nothing"

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

exports.getRandomClothing = ->
  {clothes} = require "../data/clothing"
  return "#{clothes.random()}"

exports.getRandomName = ->
  {firstNames} = require "../data/firstNames"
  {lastNames} = require "../data/lastNames"
  return "#{firstNames.random()} #{lastNames.random()}"

exports.getRandomObject = ->
  {objects} = require "../data/objects"
  return "#{objects.random()}"

exports.getRoomOnLevel = (z) ->
  ents = world.find [ "area", "room" ]
  ents = ents.filter (a) ->
    return a.area.z is z
  return ents.random()

exports.getRoomOnLevel = (z) ->
  ents = world.find [ "area", "room" ]
  ents = ents.filter (a) ->
    return a.area.z is z
  return ents.random()

exports.getTick = ->
  ents = world.find "gameClock"
  for ent in ents
    return ent.gameClock.moves

exports.getUsableAt = (ux, uy, uz) ->
  ents = world.find [ "position" ]
  ents = ents.filter (a) ->
    # don't include the player in the list of usables
    return false if a.player?
    # otherwise check if the position matches
    {x,y,z} = a.position
    return (x is ux) and (y is uy) and (z is uz)
  return ents

exports.haveDoorAt = (dx, dy, dz) ->
  ents = world.find [ "door", "position" ]
  for ent in ents
    {x,y,z} = ent.position
    if (x is dx) and (y is dy) and (z is dz)
      return true
  return false

exports.isSeeable = (wx, wy, wz) ->
  # see if anything is blocking
  ents = world.find [ "obstacle", "position" ]
  for ent in ents
    continue if ent.alien?  # aliens don't block LOS
    continue if ent.crew?   # crew don't block LOS
    continue if ent.player? # the player doesn't block LOS
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
  # next look for areas (rooms and corridors)
  ents = world.find "area"
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

exports.isStandingOnLift = (ent) ->
  return null if not ent.position?
  {x,y,z} = ent.position
  # look for lifts
  ents = world.find "lift"
  for liftEnt in ent
    lx = liftEnt.position.x
    ly = liftEnt.position.y
    lz = liftEnt.position.z
    if (lx is x) and (ly is y) and (lz is z)
      return liftEnt
  return null

exports.isWalkable = (wx, wy, wz) ->
  # see if anything is blocking
  ents = world.find [ "obstacle", "position" ]
  for ent in ents
    # continue if ent.alien?  # aliens don't block themselves
    # continue if ent.crew?   # crew don't block themselves
    # continue if ent.player? # the player doesn't block themselves
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
  # next look for areas (rooms and corridors)
  ents = world.find "area"
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

lookTargetSort = (a, b) ->
  # always sort areas last
  return 1 if a.area?
  return -1 if b.area?
  # sort non-obstacles 2nd to last
  return -1 if a.obstacle?
  return 1 if b.obstacle?
  # sort doors third to last
  return 1 if a.door?
  return -1 if b.door?
  # sort non-player crew fourth to last
  return 1 if (a.crew?) and (not a.player?)
  return -1 if (b.crew?) and (not b.player?)
  # sort aliens fifth to last
  return 1 if a.alien?
  return -1 if b.alien?
  # sort player first
  return -1 if a.player?
  return 1 if b.player?
  # otherwise we're not really sure
  return 0

#----------------------------------------------------------------------
# end of helper.coffee
