# DoorSystem.coffee
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

{DOOR_CLOSE_TICKS} = require "../config"

helper = require "../helper"

{System} = require "./System"

{Glyph} = require "../comp/Glyph"
{Obstacle} = require "../comp/Obstacle"

lastTick = 0

act = (world) ->
  # determine which tick it is
  currentTick = helper.getTick()
  # bail if the game hasn't advanced at all
  return if currentTick <= lastTick
  # for each door in the world
  ents = world.find "door"
  for ent in ents
    {door} = ent
    # if the door has been marked to open
    if door.openingAfter?
      if door.openingAfter <= currentTick
        # open the door
        door.open = true
        delete door.openingAfter
        door.closingAfter = currentTick + DOOR_CLOSE_TICKS
        glyph = new Glyph " ", ent.glyph.fg, ent.glyph.bg
        ent.glyph = glyph
        world.removeComponent ent, "obstacle"
        helper.addMessage "The door opens."
    # if the door has been marked to close
    if door.closingAfter?
      if door.closingAfter <= currentTick
        if helper.canDoorClose ent
          # close the door
          door.open = false
          delete door.closingAfter
          glyph = new Glyph "Z", ent.glyph.fg, ent.glyph.bg
          ent.glyph = glyph
          world.addComponent ent, "obstacle", new Obstacle()
          helper.addMessage "The door closes."
        else
          door.closingAfter = currentTick + DOOR_CLOSE_TICKS
          helper.addMessage "Unable to close, the door emits a warning beep."
  # mark that we've processed this tick
  lastTick = currentTick

class exports.DoorSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of DoorSystem.coffee