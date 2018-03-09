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

{Attacking} = require "../comp/Attacking"
{Lift} = require "../comp/Lift"
{MindStats} = require "../comp/MindStats"
{Target} = require "../comp/Target"

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
    # update the crew member's mood
    ent.mindStats.mood = rollNewMood world, ent
    {mood} = ent.mindStats
    # mill about randomly
    switch mood
      when MindStats.CALM
        millAbout world, ent
      when MindStats.FIGHT
        chaseOrAttackTarget world, ent
      when MindStats.FLEE
        runFromTarget world, ent
  # mark that we've processed this tick
  lastTick = currentTick

chaseLift = (world, ent, liftEnt) ->
  # the crew is here
  sx = ent.position.x
  sy = ent.position.y
  sz = ent.position.z
  # the lift is here
  dx = liftEnt.position.x
  dy = liftEnt.position.y
  dz = liftEnt.position.z
  # we can chase through any passable
  passableCallback = (x,y) ->
    walk = helper.isSeeable x, y, sz
    return true if walk.ok
    return true if walk.ent?.door?
    return false
  # compute a path from the crew
  dijkstra = new ROT.Path.Dijkstra sx, sy, passableCallback
  # these are the path computation flags
  found = false
  nx = sx
  ny = sy
  dijkstra.compute dx, dy, (x,y) ->
    # mark the fact that we found any path at all
    found = true
    # the crew doesn't want to stand still
    return if (x is sx) and (y is sy)
    # if the step is adjacent
    if helper.areCoordsAdjacent sx, sy, sz, x, y, sz
      # we'll take it
      nx = x
      ny = y
  # if the crew couldn't find any path to the lift
  if not found
    # then it's time to fight
    ent.mindStats.mood = MindStats.FIGHT
    return chaseOrAttackTarget world, ent
  # otherwise, make sure we can walk where we intend to walk
  walk = helper.isWalkable nx,ny,sz
  if walk.ok
    # update the position of the crew
    ent.position.x = nx
    ent.position.y = ny
    ent.position.z = sz
  else
    # if this is a door
    if walk.ent?.door?
      # open the damn door!
      walk.ent.door.openingAfter = helper.getTick()

chaseOrAttackTarget = (world, ent) ->
  # if the crew is standing next to the target
  if helper.areEntitiesAdjacent ent, ent.target.ent
    # attack the target
    world.addComponent ent, "attacking", new Attacking()
  else
    # chase after the target
    chaseTarget world, ent

chaseTarget = (world, ent) ->
  # the crew is here
  sx = ent.position.x
  sy = ent.position.y
  sz = ent.position.z
  # the target is here
  dx = ent.target.ent.position.x
  dy = ent.target.ent.position.y
  dz = ent.target.ent.position.z
  # we can chase through any passable
  passableCallback = (x,y) ->
    walk = helper.isSeeable x, y, sz
    return true if walk.ok
    return true if walk.ent?.door?
    return false
  # compute a path from the crew
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
  # if the crew couldn't find any path to the target
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
  else
    # if this is a door
    if walk.ent?.door?
      # open the damn door!
      walk.ent.door.openingAfter = helper.getTick()

# TODO: Thought I'd need this, but not using it. I'll keep it
#       around just in case.
damageTaken = (ent) ->
  # if we don't have an old health value, we didn't get hurt
  return false if not ent.oldHealth?
  # we took damage if old health > current health
  return ent.oldHealth.hp > ent.health.hp

millAbout = (world, ent) ->
  # if we're standing on a lift, we might take it
  liftEnt = helper.isStandingOnLift ent
  if (liftEnt?) and (ROT.RNG.getUniform() < 0.5)
    lx = liftEnt.position.x
    ly = liftEnt.position.y
    lz = liftEnt.position.z
    ent.position.x = lx
    ent.position.y = ly
    ent.position.z = lz
    return
  # otherwise, pick a random position around us
  {x,y,z} = ent.position
  x-- if ROT.RNG.getUniform() < 0.5
  x++ if ROT.RNG.getUniform() < 0.5
  y-- if ROT.RNG.getUniform() < 0.5
  y++ if ROT.RNG.getUniform() < 0.5
  walk = helper.isWalkable x,y,z
  # if we can walk there
  if walk.ok
    ent.position.x = x
    ent.position.y = y
    ent.position.z = z
  else
    # otherwise, check if it's a door we can open
    if walk.ent?
      if (walk.ent.door?) and (ent.doorUser?)
        # open the damn door
        walk.ent.door.openingAfter = helper.getTick()
        return

rollNewMood = (world, ent) ->
  # check to see if there are any aliens around
  alienSpotted = null
  ents = world.find "alien"
  for alien in ents
    # dead aliens don't count
    continue if alien.corpse?
    # otherwise, check if we can see the alien
    if helper.canEntitiesSee ent, alien
      alienSpotted = alien
      break
  # if we didn't spot any aliens, we're happy
  if not alienSpotted
    # remove any previous alien we may have spotted
    world.removeComponent ent, "target"
    return MindStats.CALM
  # set the target to our spotted alien
  world.addComponent ent, "target", new Target alienSpotted
  # if we're very brave, we'll fight
  if (ent.mindStats.bravery + ent.health.hp) > 100
    return MindStats.FIGHT
  # if we're very stupid, we'll fight
  if (ent.mindStats.intelligence < ent.health.hp)
    return MindStats.FIGHT
  # ut oh, time to run...
  return MindStats.FLEE

runFromTarget = (world, ent) ->
  {x,y,z} = ent.position
  # find the lift down on this floor
  liftDownEnt = helper.getLiftOnLevel z, Lift.DOWN
  if not liftDownEnt?
    # ut oh, no where to run
    ent.mindStats.mood = MindStats.FIGHT
    return chaseOrAttackTarget world, ent
  # otherwise, get the position of the lift
  lx = liftDownEnt.position.x
  ly = liftDownEnt.position.y
  lz = liftDownEnt.position.z
  # if we are standing on the lift down
  if (lx is x) and (ly is y) and (lz is z)
    # take the lift!
    liftUpEnt = helper.getLiftOnLevel z+1, Lift.UP
    if not liftUpEnt?
      throw new Error "lift down on #{z} but no lift up on #{z+1}???"
    lx = liftUpEnt.position.x
    ly = liftUpEnt.position.y
    lz = liftUpEnt.position.z
    ent.position.x = lx
    ent.position.y = ly
    ent.position.z = lz
    return
  # otherwise we need to take a step toward the lift
  chaseLift world, ent, liftDownEnt

class exports.CrewThinkSystem extends System
  act: -> run @world, @engine

#----------------------------------------------------------------------
# end of CrewThinkSystem.coffee
