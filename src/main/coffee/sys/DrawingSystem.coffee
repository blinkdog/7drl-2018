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
  HEIGHT: 30

MESSAGE_HEIGHT = 4

_ = require "lodash"
{System} = require "./System"

display = null

act = (world) ->
  # first, ensure that we've got a display
  createDisplay() if not display?
  # draw everything that needs to be drawn
  display.clear()
  drawDebugPattern()
  drawMap world
  drawMessages world
  drawStatusLine world
  # return something reasonable to the caller
  return true

clearLine = (y, bg) ->
  bg ?= "#000"
  for x in [0...DISPLAY_SIZE.WIDTH]
    display.draw x, y, "", "#fff", bg
  return true

createDisplay = (world) ->
  console.log "Creating ROT.Display (#{DISPLAY_SIZE.WIDTH}x#{DISPLAY_SIZE.HEIGHT})"
  # create the display and add it to the world
  display = new ROT.Display
    layout: "rect"
    width: DISPLAY_SIZE.WIDTH
    height: DISPLAY_SIZE.HEIGHT
  # add the display to the browser
  document.body.innerHTML = ''
  document.body.appendChild display.getContainer()
  # return something reasonable to the caller
  return display

# DEBUG: Fill the grid with magic pink hashes
drawDebugPattern = ->
  for y in [0...DISPLAY_SIZE.HEIGHT]
    for x in [0...DISPLAY_SIZE.WIDTH]
      display.draw x, y, "#", "#f0f", "#000"

drawMap = (world) ->
  # find everything that we can draw
  ents = world.find [ "glyph", "position" ]
  # TODO: may need to sort these ents by Z value (painter's algorithm)
  for ent in ents
    # draw everything that we can draw
    display.draw ent.position.x, ent.position.y, ent.glyph.ch, ent.glyph.fg, ent.glyph.bg

drawMessages = (world) ->
  # clear some lines for messages
  for y in [0...MESSAGE_HEIGHT]
    clearLine y, "#000"
  # locate the message log
  ents = world.find "messages"
  for ent in ents
    {log} = ent.messages
    # display the most recent messages
    showMe = log.slice -MESSAGE_HEIGHT
    for y in [0...showMe.length]
      display.drawText 0, y, showMe[y]

drawStatusLine = (world) ->
  # determine where in the world the player is currently situated
  posX = 0
  posY = 0
  posZ = 0
  ents = world.find [ "player", "position" ]
  for ent in ents
    posX = ent.position.x
    posY = ent.position.y
    posZ = ent.position.z
  # determine where we're going to draw the status line
  STATUS_Y = DISPLAY_SIZE.HEIGHT-1
  # clear a line for the status display
  clearLine STATUS_Y, "#777"
  # draw some status text
  display.drawText 1, STATUS_Y, "%b{#777}%c{#000}X:#{posX} Y:#{posY} Z:#{posZ}"

class exports.DrawingSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of DrawingSystem.coffee
