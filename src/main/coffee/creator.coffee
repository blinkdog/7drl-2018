# creator.coffee
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

STATION_SIZE =
  WIDTH: 80
  HEIGHT: 25
  LEVELS: 100

helper = require "./helper"

{Camera} = require "./comp/Camera"
{Corridor} = require "./comp/Corridor"
{Door} = require "./comp/Door"
{Room} = require "./comp/Room"
{GameMode} = require "./comp/GameMode"
{Glyph} = require "./comp/Glyph"
{Messages} = require "./comp/Messages"
{Name} = require "./comp/Name"
{Player} = require "./comp/Player"
{Position} = require "./comp/Position"

exports.create = (world) ->
  # create our game
  ent = world.createEntity()
  gameMode = new GameMode()
  world.addComponent ent, "gameMode", gameMode

  # create the messages log
  ent = world.createEntity()
  messages = new Messages()
  world.addComponent ent, "messages", messages

  # create the station layout
  for i in [1..STATION_SIZE.LEVELS]
    map = new ROT.Map.Digger STATION_SIZE.WIDTH, STATION_SIZE.HEIGHT
    map.create()
    # create a room entity for each room
    for room in map.getRooms()
      ent = world.createEntity()
      roomComp = new Room room.getLeft(), room.getTop(), room.getRight(), room.getBottom(), i
      world.addComponent ent, "room", roomComp
      glyph = new Glyph ".", "#777", "#000"
      world.addComponent ent, "glyph", glyph
      # create a door entity for each door
      room.getDoors (x, y) ->
        ent = world.createEntity()
        door = new Door x, y, i
        world.addComponent ent, "door", door
        glyph = new Glyph "Z", "#777", "#000"
        world.addComponent ent, "glyph", glyph
    # create a corridor entity for each corridor
    for corridor in map.getCorridors()
      ent = world.createEntity()
      corridorComp = new Corridor corridor._startX, corridor._startY, corridor._endX, corridor._endY, i
      world.addComponent ent, "corridor", corridorComp
      glyph = new Glyph ".", "#777", "#000"
      world.addComponent ent, "glyph", glyph

  # create our protagonist
  ent = world.createEntity()
  myNameIs = helper.getRandomName()
  player = new Player myNameIs
  world.addComponent ent, "player", player
  name = new Name myNameIs
  world.addComponent ent, "name", name
  glyph = new Glyph "@"
  world.addComponent ent, "glyph", glyph
  {room} = helper.getNearestRoom 0, STATION_SIZE.HEIGHT, STATION_SIZE.LEVELS
  roomX = Math.floor (room.x1+room.x2) / 2
  roomY = Math.floor (room.y1+room.y2) / 2
  position = new Position roomX, roomY, STATION_SIZE.LEVELS
  world.addComponent ent, "position", position

  # create our camera
  ent = world.createEntity()
  camera = new Camera position.x, position.y, position.z
  world.addComponent ent, "camera", camera

  # add a message to the world about our protagonist
  messages.log.push "" for x in [0..3]
  messages.log.push "I am #{name.name}, station cargo handler."

#----------------------------------------------------------------------
# end of creator.coffee
