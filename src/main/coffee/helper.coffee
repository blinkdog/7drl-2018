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
      if ent.name?
        return ent.name.name
      else
        return "An object"
  # next look for doors
  ents = world.find "door"
  for ent in ents
    {x, y, z} = ent.door
    if (lx is x) and (ly is y) and (lz is z)
      if ent.door.open
        return "Door (Open)"
      else
        return "Door (Closed)"
  # next look for corridors
  ents = world.find "corridor"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.corridor
    if (lx >= x1) and (lx <= x2) and (ly >= y1) and (ly <= y2) and (lz is z)
      return "Corridor"
  # next look for rooms
  ents = world.find "room"
  for ent in ents
    {x1, y1, x2, y2, z} = ent.room
    if (lx >= x1) and (lx <= x2) and (ly >= y1) and (ly <= y2) and (lz is z)
      return "Room"
  # can't find anything at that location
  return "Nothing"

exports.getNearestRoom = (x, y, z) ->
  nearestRoom = null
  minDist = 4294967295
  # for every room in the world
  ents = world.find "room"
  for ent in ents
    {room} = ent
    # skip any rooms that aren't on the same level
    continue if room.z isnt z
    # determine the center of the room
    cx = Math.floor (room.x1+room.x2) / 2
    cy = Math.floor (room.y1+room.y2) / 2
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

#----------------------------------------------------------------------
# end of helper.coffee
