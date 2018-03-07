# CorpseSystem.coffee
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

{Corpse} = require "../comp/Corpse"
{GameMode} = require "../comp/GameMode"

act = (world) ->
  # find anything with health
  ents = world.find "health"
  # for each thing that could die
  for ent in ents
    # skip them if they're already dead
    continue if ent.corpse?
    # if their health dipped below zero
    {hp} = ent.health
    if hp < 1
      # set their hp to exactly zero
      ent.health.hp = 0
      # mark them as a corpse
      world.addComponent ent, "corpse", new Corpse()
      # change their name to reflect their current status
      if ent.name?
        {name} = ent.name
        ent.name.name = "Corpse of #{name}"
      # remove obstacle; we can walk over corpses
      world.removeComponent ent, "obstacle"
      # if this is the player... ut oh
      if ent.player?
        helper.setGameMode GameMode.LOSE
        helper.addMessage "You succumb to your injuries."
        helper.addMessage "Game Over. Please reload to start a new game."

class exports.CorpseSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of CorpseSystem.coffee
