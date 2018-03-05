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

DISPLAY_SIZE =
  WIDTH: 80
  HEIGHT: 25

_ = require "lodash"
{System} = require "./System"

display = null

act = (world) ->
  # first, ensure that we've got a display
  createDisplay() if not display?
  # clear the display to get ready for a new drawing cycle
  display.clear()
  # DEBUG: Fill the grid with magic pink hashes
  for y in [0...25]
    for x in [0...80]
      display.draw x, y, "#", "#f0f", "#000"
  # find everything that we can draw
  ents = world.find [ "glyph", "position" ]
  # TODO: may need to sort these ents by Z value (painter's algorithm)
  for ent in ents
    # draw everything that we can draw
    display.draw ent.position.x, ent.position.y, ent.glyph.ch, ent.glyph.fg, ent.glyph.bg
  # clear some lines for status and messages
  for y in [DISPLAY_SIZE.HEIGHT-5...DISPLAY_SIZE.HEIGHT-1]
    clearLine y, "#000"
  clearLine DISPLAY_SIZE.HEIGHT-1, "#fff"
  # return something reasonable to the caller
  return true

clearLine = (y, bg) ->
  bg ?= "#000"
  for x in [0...DISPLAY_SIZE.WIDTH]
    display.draw x, y, "", "#fff", bg
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
