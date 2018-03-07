# RadiationSystem.coffee
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

{FLOODED_WITH_RADIATION} = require "./config"

helper = require "../helper"

{System} = require "./System"

lastTick = 0

act = (world) ->
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # find the player
  player = helper.getPlayer()
  # if the station is flooded with radiation
  if FLOODED_WITH_RADIATION
    # subject the player to radiation damage
    player.health.hp--
    player.health.rads++
  # mark that we've processed this tick
  lastTick = currentTick

class exports.RadiationSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of RadiationSystem.coffee
