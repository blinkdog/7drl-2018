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

{ALIEN, CREW, DOOR, ITEM, STATION_SIZE} = require "./config"

helper = require "./helper"

{Alien} = require "./comp/Alien"
{AlienShip} = require "./comp/AlienShip"
{Area} = require "./comp/Area"
{Camera} = require "./comp/Camera"
{CombatStats} = require "./comp/CombatStats"
{Corridor} = require "./comp/Corridor"
{Crew} = require "./comp/Crew"
{Door} = require "./comp/Door"
{DoorUser} = require "./comp/DoorUser"
{Room} = require "./comp/Room"
{GameClock} = require "./comp/GameClock"
{GameMode} = require "./comp/GameMode"
{Glyph} = require "./comp/Glyph"
{Health} = require "./comp/Health"
{HighExplosives} = require "./comp/HighExplosives"
{Inventory} = require "./comp/Inventory"
{Item} = require "./comp/Item"
{Lift} = require "./comp/Lift"
{LiftRoom} = require "./comp/LiftRoom"
{LiftUser} = require "./comp/LiftUser"
{Messages} = require "./comp/Messages"
{MindStats} = require "./comp/MindStats"
{Name} = require "./comp/Name"
{Obstacle} = require "./comp/Obstacle"
{OldHealth} = require "./comp/OldHealth"
{Player} = require "./comp/Player"
{Position} = require "./comp/Position"
{ShipRoom} = require "./comp/ShipRoom"
{StartRoom} = require "./comp/StartRoom"

addLiftToLevel = (world, level, dir) ->
  # find rooms where we could put a lift
  ents = world.find [ "area", "room" ]
  ents = ents.filter (x) ->
    # don't put a lift in the starting room
    return false if x.startRoom?
    # don't put a lift in the ending room
    return false if x.shipRoom?
    # don't put two lifts in a single room
    return false if x.liftRoom?
    # don't put lifts in rooms on other levels
    return false if x.area.z isnt level
    # otherwise it should be ok
    return true
  # pick one of the candidate rooms at random
  if ents.length < 1
    throw new Error "not enough rooms on floor #{level}"
  liftRoomEnt = ents.random()
  # mark the room as a lift room
  world.addComponent liftRoomEnt, "liftRoom", new LiftRoom()
  # figure out where to put the lift in the room
  {area} = liftRoomEnt
  lx = ROT.RNG.getUniformInt area.x1, area.x2
  ly = ROT.RNG.getUniformInt area.y1, area.y2
  if dir is Lift.UP
    ch = "/"
    name = "Lift (Up)"
  else
    ch = "\\"
    name = "Lift (Down)"
  # create the lift in the world
  build world,
    glyph: new Glyph ch, "#777", "#000"
    lift: new Lift dir
    name: new Name name
    position: new Position lx, ly, level

build = (world, spec) ->
  ent = world.createEntity()
  for key of spec
    if spec[key]?
      world.addComponent ent, key, spec[key]
  return ent

createHighExplosives = ->
  return
    name: "High Explosives"
    type: "highExplosives"
    comp: new HighExplosives()

createRandomItem = (index) ->
  return createHighExplosives() if index is 1
  name = "Useless Junk"
  if ROT.RNG.getUniform() < 0.5
    name = helper.getRandomClothing()
  else
    name = helper.getRandomObject()
  return
    name: name

pickItemRoom = ->
  # until we find a room we like
  roomEnt = null
  while not roomEnt?
    # pick a floor for the item
    z = ROT.RNG.getUniformInt ITEM.MIN_FLOOR, ITEM.MAX_FLOOR
    # choose a random room on that level
    roomEnt = helper.getRoomOnLevel z
    # veto all lift rooms and the final room
    if (roomEnt.liftRoom?) or (roomEnt.liftRoom?)
      roomEnt = null
  # return the chosen room to the caller
  return roomEnt

rollAlienCombatStats = ->
  attack = 50 + ROT.RNG.getUniformInt -20, 20
  defense = 30 + ROT.RNG.getUniformInt -10, 10
  strength = 50 + ROT.RNG.getUniformInt -20, 20
  return new CombatStats attack, defense, strength

rollCrewCombatStats = ->
  attack = 50 + ROT.RNG.getUniformInt -20, 20
  defense = 40 + ROT.RNG.getUniformInt -10, 10
  strength = 30 + ROT.RNG.getUniformInt -5, 5
  return new CombatStats attack, defense, strength

rollCrewMindStats = ->
  bravery = 50 + ROT.RNG.getUniformInt -30, 30
  intelligence = 50 + ROT.RNG.getUniformInt -30, 30
  mood = MindStats.CALM
  return new MindStats bravery, intelligence, mood

exports.create = (world) ->
  # create our game
  build world,
    gameClock: new GameClock 0
  build world,
    gameMode: new GameMode GameMode.PLAY

  # create the messages log
  build world,
    messages: new Messages()

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
        glyph = new Glyph DOOR.CLOSED.CH, DOOR.CLOSED.FG, DOOR.CLOSED.BG
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
  startRoomEnt = helper.getNearestRoom 0, STATION_SIZE.HEIGHT, STATION_SIZE.LEVELS
  world.addComponent startRoomEnt, "startRoom", new StartRoom()
  {area} = startRoomEnt
  roomX = Math.floor (area.x1+area.x2) / 2
  roomY = Math.floor (area.y1+area.y2) / 2
  build world,
    combatStats: rollCrewCombatStats()
    crew: new Crew()
    glyph: new Glyph "@"
    health: new Health()
    inventory: new Inventory()
    name: new Name helper.getRandomName()
    obstacle: new Obstacle()
    oldHealth: new OldHealth()
    player: new Player()
    position: new Position roomX, roomY, STATION_SIZE.LEVELS

  # add a message to the world about our protagonist
  {name} = helper.getPlayer()
  #helper.addMessage "I am #{name.name}, station cargo handler."
  helper.addMessage "I am station cargo handler #{name.name}."

  # create our camera
  {position} = helper.getPlayer()
  build world,
    camera: new Camera position.x, position.y, position.z

  # pick a ship room on the top floor
  ents = world.find [ "room" ]
  ents = ents.filter (x) ->
    return false if x.area.z isnt 1
    return true
  shipRoomEnt = ents.random()
  world.addComponent shipRoomEnt, "shipRoom", new ShipRoom()

  # create the alien ship
  {area} = shipRoomEnt
  ax = ROT.RNG.getUniformInt area.x1, area.x2
  ay = ROT.RNG.getUniformInt area.y1, area.y2
  az = area.z
  build world,
    alienShip: new AlienShip()
    glyph: new Glyph "A", "#000", "#0f0"
    name: new Name "The Alien Ship"
    obstacle: new Obstacle()
    position: new Position ax, ay, az

  # create lift on the top and bottom floors
  addLiftToLevel world, STATION_SIZE.LEVELS, Lift.UP
  addLiftToLevel world, 1, Lift.DOWN

  # create lifts on the intermediate floors
  for i in [2...STATION_SIZE.LEVELS]
    addLiftToLevel world, i, Lift.UP
    addLiftToLevel world, i, Lift.DOWN

  # create station crew members
  for i in [1..CREW.NUM_PRESENT]
    # pick a floor for the crew member
    cz = ROT.RNG.getUniformInt CREW.MIN_FLOOR, CREW.MAX_FLOOR
    roomEnt = helper.getRoomOnLevel cz
    # find a spot within the room
    {area} = roomEnt
    cx = ROT.RNG.getUniformInt area.x1, area.x2
    cy = ROT.RNG.getUniformInt area.y1, area.y2
    # create a crew member there
    build world,
      combatStats: rollCrewCombatStats()
      crew: new Crew()
      doorUser: new DoorUser()
      glyph: new Glyph "C", "#77a", "#000"
      health: new Health()
      inventory: new Inventory()
      liftUser: new LiftUser()
      mindStats: rollCrewMindStats()
      name: new Name helper.getRandomName()
      obstacle: new Obstacle()
      position: new Position cx, cy, cz

  # create aliens
  for i in [1..ALIEN.NUM_PRESENT]
    # pick a floor for the alien
    cz = ROT.RNG.getUniformInt ALIEN.MIN_FLOOR, ALIEN.MAX_FLOOR
    roomEnt = helper.getRoomOnLevel cz
    # find a spot within the room
    {area} = roomEnt
    cx = ROT.RNG.getUniformInt area.x1, area.x2
    cy = ROT.RNG.getUniformInt area.y1, area.y2
    # see if this alien likes to use doors or lifts
    doorUser = null
    liftUser = null
    if ROT.RNG.getUniform() < ALIEN.DOOR_USE
      doorUser = new DoorUser()
    if ROT.RNG.getUniform() < ALIEN.LIFT_USE
      liftUser = new LiftUser()
    # create an alien there
    build world,
      alien: new Alien()
      combatStats: rollAlienCombatStats()
      doorUser: doorUser
      glyph: new Glyph "S", "#696", "#000"
      health: new Health()
      liftUser: liftUser
      name: new Name "Alien"
      obstacle: new Obstacle()
      position: new Position cx, cy, cz

  # create items
  for i in [1..ITEM.NUM_PRESENT]
    # pick a room to put the item in
    roomEnt = pickItemRoom()
    # find a spot within the room
    {area} = roomEnt
    cx = ROT.RNG.getUniformInt area.x1, area.x2
    cy = ROT.RNG.getUniformInt area.y1, area.y2
    cz = area.z
    # create an item type
    itemSpec = createRandomItem i
    # create an item there
    itemEnt = build world,
      glyph: new Glyph "q", "#966", "#000"
      health: new Health()
      name: new Name itemSpec.name
      position: new Position cx, cy, cz
    # not all items needs it, and the type key is dynamic, so
    # rather than complicate the above builder pattern, we'll
    # just add the dynamic key after the fact if necessary
    if itemSpec.type?
      world.addComponent itemEnt, itemSpec.type, itemSpec.comp

#----------------------------------------------------------------------
# end of creator.coffee
