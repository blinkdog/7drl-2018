# CrewThinkSystem.coffee
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

lastTick = 0

run = (world, engine) ->
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # for each crew in the world
  ents = world.find "crew"
  for ent in ents
    # dead crew don't think
    continue if ent.corpse?
    # the player can think for themselves
    continue if ent.player?
    # mill about randomly
    {x,y,z} = ent.position
    x-- if ROT.RNG.getUniform() < 0.5
    x++ if ROT.RNG.getUniform() < 0.5
    y-- if ROT.RNG.getUniform() < 0.5
    y++ if ROT.RNG.getUniform() < 0.5
    walk = helper.isWalkable x,y,z
    if walk.ok
      ent.position.x = x
      ent.position.y = y
      ent.position.z = z
  # mark that we've processed this tick
  lastTick = currentTick

class exports.CrewThinkSystem extends System
  act: -> run @world, @engine

#----------------------------------------------------------------------
# end of CrewThinkSystem.coffee
