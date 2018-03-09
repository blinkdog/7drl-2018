# game.coffee
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

{World} = require "index-ecs"

audio = require "./audio"
creator = require "./creator"
helper = require "./helper"

{AlienThinkSystem} = require "./sys/AlienThinkSystem"
{CombatSystem} = require "./sys/CombatSystem"
{CorpseSystem} = require "./sys/CorpseSystem"
{CrewThinkSystem} = require "./sys/CrewThinkSystem"
{DoorSystem} = require "./sys/DoorSystem"
{DrawingSystem} = require "./sys/DrawingSystem"
{InputSystem} = require "./sys/InputSystem"
{PlayerThinkSystem} = require "./sys/PlayerThinkSystem"
{RadiationSystem} = require "./sys/RadiationSystem"

engine = null
world = null

preFlightChecks = ->
  return "rot.js is not supported" if not ROT.isSupported()
  return null

exports.run = ->
  # if there is any trouble
  reason = preFlightChecks()
  return alert reason if reason?
  # set the random seed
  seed = Date.now()
  ROT.RNG.setSeed seed
  console.log "Game begins with seed #{seed}!"
  # create the World so we can start populating it
  world = new World()
  helper.setWorld world
  creator.create world
  # create the engine to run our world
  scheduler = new ROT.Scheduler.Simple()
  engine = new ROT.Engine scheduler
  # create the systems that will animate our world
  scheduler.add new DrawingSystem(world, engine), true
  scheduler.add new InputSystem(world, engine), true
  scheduler.add new PlayerThinkSystem(world, engine), true
  scheduler.add new CrewThinkSystem(world, engine), true
  scheduler.add new AlienThinkSystem(world, engine), true
  scheduler.add new DoorSystem(world, engine), true
  scheduler.add new RadiationSystem(world, engine), true
  scheduler.add new CombatSystem(world, engine), true
  scheduler.add new CorpseSystem(world, engine), true
  # run the main loop
  engine.start()

#----------------------------------------------------------------------
# end of game.coffee
