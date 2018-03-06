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

{STATION_SIZE} = require "./config"

helper = require "./helper"

{Area} = require "./comp/Area"
{Camera} = require "./comp/Camera"
{Corridor} = require "./comp/Corridor"
{Door} = require "./comp/Door"
{Room} = require "./comp/Room"
{GameClock} = require "./comp/GameClock"
{GameMode} = require "./comp/GameMode"
{Glyph} = require "./comp/Glyph"
{Messages} = require "./comp/Messages"
{Name} = require "./comp/Name"
{Obstacle} = require "./comp/Obstacle"
{Player} = require "./comp/Player"
{Position} = require "./comp/Position"

exports.create = (world) ->
  # create our game
  ent = world.createEntity()
  gameClock = new GameClock 0
  world.addComponent ent, "gameClock", gameClock
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
      area = new Area room.getLeft(), room.getTop(), room.getRight(), room.getBottom(), i
      world.addComponent ent, "area", area
      roomComp = new Room()
      world.addComponent ent, "room", roomComp
      glyph = new Glyph ".", "#777", "#000"
      world.addComponent ent, "glyph", glyph
      # create a door entity for each door
      room.getDoors (x, y) ->
        # NOTE: generator will provide overlapping doors
        return if helper.haveDoorAt x, y, i
        # no door there yet, so let's create *one*
        ent = world.createEntity()
        door = new Door Door.CLOSED
        world.addComponent ent, "door", door
        glyph = new Glyph "Z", "#777", "#000"
        world.addComponent ent, "glyph", glyph
        obstacle = new Obstacle()
        world.addComponent ent, "obstacle", obstacle
        position = new Position x, y, i
        world.addComponent ent, "position", position
    # create a corridor entity for each corridor
    for corridor in map.getCorridors()
      ent = world.createEntity()
      oc = helper.order corridor._startX, corridor._startY, corridor._endX, corridor._endY
      area = new Area oc.x1, oc.y1, oc.x2, oc.y2, i
      world.addComponent ent, "area", area
      corridorComp = new Corridor()
      world.addComponent ent, "corridor", corridorComp
      glyph = new Glyph ".", "#777", "#000"
      world.addComponent ent, "glyph", glyph

  # create our protagonist
  ent = world.createEntity()
  glyph = new Glyph "@"
  world.addComponent ent, "glyph", glyph
  name = new Name helper.getRandomName()
  world.addComponent ent, "name", name
  obstacle = new Obstacle()
  world.addComponent ent, "obstacle", obstacle
  player = new Player()
  world.addComponent ent, "player", player
  {area} = helper.getNearestRoom 0, STATION_SIZE.HEIGHT, STATION_SIZE.LEVELS
  roomX = Math.floor (area.x1+area.x2) / 2
  roomY = Math.floor (area.y1+area.y2) / 2
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
