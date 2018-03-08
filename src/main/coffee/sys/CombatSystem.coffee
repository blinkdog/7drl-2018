# CombatSystem.coffee
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

act = (world) ->
  # we'll need to remove the 'attacking' component later
  stopAttacking = []
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # find any attacking entities
  ents = world.find "attacking"
  for ent in ents
    # we'll need to remove the 'attacking' component later
    stopAttacking.push ent
    # if no target is specified, cancel the attack
    continue if not ent.target?
    # if the target has no health, cancel the attack
    targetEnt = ent.target.ent
    continue if not targetEnt.health?
    continue if targetEnt.health.hp < 1
    # if the target is already dead, cancel the attack
    continue if targetEnt.corpse?
    # if the attacker aims well enough to hit
    acs = ent.combatStats
    dcs = targetEnt.combatStats
    ax = ent.position.x
    ay = ent.position.y
    az = ent.position.z
    if ROT.RNG.getPercentage() <= acs.attack
      # if the defender fails to defend
      if ROT.RNG.getPercentage() > dcs.defense
        # inflict damage on the defender
        dmg = Math.floor(ROT.RNG.getUniform() * acs.strength)+1
        targetEnt.health.hp -= dmg
        targetEnt.health.hurt += dmg
        helper.addMessageAt ax, ay, az, "#{ent.name.name} inflicts #{dmg} points of damage on #{targetEnt.name.name}"
      else
        helper.addMessageAt ax, ay, az, "#{targetEnt.name.name} narrowly avoids the attack by #{ent.name.name}."
    else
      helper.addMessageAt ax, ay, az, "#{ent.name.name} missed #{targetEnt.name.name}."
  # mark that we've processed this tick
  lastTick = currentTick
  # remove the attacking component from all entities
  for ent in stopAttacking
    world.removeComponent ent, "attacking"

class exports.CombatSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of CombatSystem.coffee
