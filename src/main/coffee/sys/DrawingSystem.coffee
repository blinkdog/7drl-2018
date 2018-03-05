# DrawingSystem.coffee
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

_ = require "lodash"
{System} = require "./System"

display = null

act = (world) ->
  # first, ensure that we've got a display
  createDisplay() if not display?
  # clear the display to get ready for a new drawing cycle
  display.clear()
  # find everything that we can draw
  ents = world.find [ "glyph", "position" ]
  # TODO: may need to sort these ents by Z value (painter's algorithm)
  for ent in ents
    # draw everything that we can draw
    display.draw ent.position.x, ent.position.y, ent.glyph.ch, ent.glyph.fg, ent.glyph.bg
  # return something reasonable to the caller
  return true

createDisplay = (world) ->
  console.log "Creating ROT.Display (80x25)"
  # create the display and add it to the world
  display = new ROT.Display
    layout: "rect"
    width: 80
    height: 25
  # add the display to the browser
  document.body.innerHTML = ''
  document.body.appendChild display.getContainer()
  # return something reasonable to the caller
  return display

class exports.DrawingSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of DrawingSystem.coffee
