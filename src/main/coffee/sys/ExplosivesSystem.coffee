# ExplosivesSystem.coffee
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

helper = require "../helper"

{System} = require "./System"

{GameMode} = require "../comp/GameMode"

lastTick = 0

run = (world, engine) ->
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # for each door in the world
  ents = world.find "highExplosives"
  for ent in ents
    he = ent.highExplosives
    # if the explosives have been marked to explode
    if he.detonateAfter?
      if he.detonateAfter <= currentTick
        player = helper.getPlayer()
        alienShipDestroyed = false
        playerDies = false
        # check the position of the explosives
        posEnt = ent
        # if the explosives are still in the player's inventory
        if not ent.position?
          # check the position of the player
          playerDies = true
          posEnt = player
        # determine where the explosives are located
        {position} = posEnt
        checkEnts = helper.getEntsAt position
        for checkEnt in checkEnts
          if checkEnt.shipRoom?
            alienShipDestroyed = true
            break
        # if the player can see the explosives
        if posEnt is ent
          if helper.canEntitiesSee player, ent
            playerDies = true
        # determine where the player is
        {position} = player
        inShipRoom = false
        checkEnts = helper.getEntsAt player.position
        for checkEnt in checkEnts
          if checkEnt.shipRoom?
            if alienShipDestroyed
              playerDies = true
        # determine the outcome of the explosion
        if (playerDies) and (not alienShipDestroyed)
          return killedByExplosives()
        if (playerDies) and (alienShipDestroyed)
          return dieAHero()
        if (not playerDies) and (not alienShipDestroyed)
          return wastedExplosives()
        if (not playerDies) and (alienShipDestroyed)
          return winTheGame()
  # mark that we've processed this tick
  lastTick = currentTick

dieAHero = ->
  helper.addMessage "The High Explosives blow The Alien Ship to hell!"
  helper.addMessage "Your noble sacrifice will be remembered forever."
  helper.addMessage "Humanity wins! Please reload to start a new game."
  helper.setGameMode GameMode.WIN

killedByExplosives = ->
  helper.addMessage "The High Explosives emit a very loud beep."
  helper.addMessage "It is the last sound that you ever hear."
  helper.addMessage "Game Over. Please reload to start a new game."
  helper.setGameMode GameMode.LOSE

wastedExplosives = ->
  helper.addMessage "The High Explosives fail to destroy The Alien Ship."
  helper.addMessage "You have doomed the human race."
  helper.addMessage "Game Over. Please reload to start a new game."
  helper.setGameMode GameMode.LOSE

winTheGame = ->
  helper.addMessage "The High Explosives blow The Alien Ship to hell!"
  helper.addMessage "You saved the human race with your heroic deeds!"
  helper.addMessage "Humanity wins! Please reload to start a new game."
  helper.setGameMode GameMode.WIN

class exports.ExplosivesSystem extends System
  act: -> run @world, @engine

#----------------------------------------------------------------------
# end of ExplosivesSystem.coffee
