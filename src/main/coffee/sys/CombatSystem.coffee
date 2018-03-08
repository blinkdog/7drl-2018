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

stopAttacking = []

act = (world) ->
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # find any attacking entities
  ents = world.find "attacking"
  for ent in ents
    # if no target is specified, cancel the attack
    if not ent.target?
      stopAttacking.push ent
      continue
    # if the target has no health, cancel the attack
    targetEnt = ent.target.ent
    if not targetEnt.health?
      stopAttacking.push ent
      continue
    if targetEnt.health.hp < 1
      stopAttacking.push ent
      continue
    # if the target is already dead, cancel the attack
    if targetEnt.corpse?
      stopAttacking.push ent
      continue
    # if the attacker aims well enough to hit
    acs = ent.combatStats
    dcs = targetEnt.combatStats
    if ROT.RNG.getPercentage() <= acs.attack
      # if the defender fails to defend
      if ROT.RNG.getPercentage() > dcs.defense
        # inflict damage on the defender
        dmg = Math.floor(ROT.RNG.getUniform() * acs.strength)+1
        targetEnt.health.hp -= dmg
        targetEnt.health.hurt += dmg
        helper.addMessage "#{ent.name.name} inflicts #{dmg} points of damage on #{targetEnt.name.name}"
      else
        helper.addMessage "#{targetEnt.name.name} narrowly avoids the attack by #{ent.name.name}."
    else
      helper.addMessage "#{ent.name.name} missed #{targetEnt.name.name}."
    # in any case, this attack is over
    stopAttacking.push ent
  # mark that we've processed this tick
  lastTick = currentTick
  # remove the attacking component from all resolved attacks
  for ent in stopAttacking
    world.removeComponent ent, "attacking"

class exports.CombatSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of CombatSystem.coffee
