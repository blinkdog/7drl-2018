# AlienThinkSystem.coffee
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

{Attacking} = require "../comp/Attacking"
{Target} = require "../comp/Target"

lastTick = 0

act = (world) ->
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # for each alien in the world
  ents = world.find "alien"
  for ent in ents
    # dead aliens don't think
    continue if ent.corspe?

    # if an alien has a target
    if ent.target?
      # if the target is dead
      if (ent.target.ent.corpse?) or (ent.target.ent.health.hp < 1)
        # they are no longer the target
        world.removeComponent ent, "target"

    # if an alien doesn't have a target
    if not ent.target?
      # try to find a target
      crewEnts = world.find "crew"
      for crewEnt in crewEnts
        # we don't target dead crew members
        continue if crewEnt.corpse?
        continue if crewEnt.health.hp < 1
        # if the alien can see the crew member
        if helper.canEntitiesSee ent, crewEnt
          world.addComponent ent, "target", new Target crewEnt
          break

    # if the alien has target
    if ent.target?
      chaseOrAttackTarget world, ent
    # otherwise the alien didn't find a target
    else
      millAbout ent
  # mark that we've processed this tick
  lastTick = currentTick

chaseTarget = (world, ent) ->
  # the alien is here
  sx = ent.position.x
  sy = ent.position.y
  sz = ent.position.z
  # the target is here
  dx = ent.target.ent.position.x
  dy = ent.target.ent.position.y
  dz = ent.target.ent.position.z
  # we can chase through any passable
  passableCallback = (x,y) ->
    walk = helper.isWalkable x, y, sz
    return walk.ok
  # compute a path from the alien
  dijkstra = new ROT.Path.Dijkstra sx, sy, passableCallback
  # these are the path computation flags
  found = false
  nx = sx
  ny = sy
  dijkstra.compute dx, dy, (x,y) ->
    # mark the fact that we found any path at all
    found = true
    # the alien doesn't want to stand still
    return if (x is sx) and (y is sy)
    # if the step is adjacent
    if helper.areCoordsAdjacent sx, sy, sz, x, y, sz
      # we'll take it
      nx = x
      ny = y
  # if the alien couldn't find any path to the target
  if not found
    # then just give up on that target
    world.removeComponent ent, "target"
    return
  # otherwise, make sure we can walk where we intend to walk
  walk = helper.isWalkable nx,ny,sz
  if walk.ok
    # update the position of the alien
    ent.position.x = nx
    ent.position.y = ny
    ent.position.z = sz

chaseOrAttackTarget = (world, ent) ->
  # if the alien is standing next to the target
  if helper.areEntitiesAdjacent ent, ent.target.ent
    # attack the target
    world.addComponent ent, "attacking", new Attacking()
  else
    # chase after the target
    chaseTarget world, ent

millAbout = (ent) ->
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

class exports.AlienThinkSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of AlienThinkSystem.coffee
