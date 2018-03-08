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
{RadiationSystem} = require "./sys/RadiationSystem"

alienThinkSystem = null
combatSystem = null
corpseSystem = null
crewThinkSystem = null
doorSystem = null
drawingSystem = null
inputSystem = null
radiationSystem = null

world = null

loopAgain = false
loopRunning = false

exports.next = ->
  if loopRunning
    loopAgain = true
  else
    loopRunning = true
    setTimeout (-> mainLoop()), 1

mainLoop = ->
  # raise the loop flag
  loopRunning = true
  # TODO: Run the game's main loop here
  inputSystem.run()
  crewThinkSystem.run()
  alienThinkSystem.run()
  doorSystem.run()
  radiationSystem.run()
  combatSystem.run()
  corpseSystem.run()
  drawingSystem.run()
  # drop the loop flag
  loopRunning = false
  # if something set the loop again flag, do that
  if loopAgain
    loopAgain = false
    loopRunning = true
    setTimeout (-> mainLoop()), 1

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
  # create the systems that will animate our world
  alienThinkSystem = new AlienThinkSystem world
  combatSystem = new CombatSystem world
  corpseSystem = new CorpseSystem world
  crewThinkSystem = new CrewThinkSystem world
  doorSystem = new DoorSystem world
  drawingSystem = new DrawingSystem world
  inputSystem = new InputSystem world
  radiationSystem = new RadiationSystem world
  # run the main loop
  mainLoop()

# debugging in browser
exports.world = world
window.API.game = exports if window?.API?

#----------------------------------------------------------------------
# end of game.coffee
