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

exports.getPlayer = ->
  return null if not world?
  ents = world.find "player"
  for ent in ents
    return ent
  return null

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

exports.setWorld = (x) ->
  world = x

#----------------------------------------------------------------------
# end of helper.coffee
