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
helper = require "../helper"
{System} = require "./System"

display = null

act = (world) ->
  # first, ensure that we've got a display
  createDisplay() if not display?
  # get the position of the camera
  camera = getCamera()
  # draw everything that needs to be drawn
  display.clear()
  drawDebugPattern()
  drawMap world, camera
  drawObjects world, camera
  drawMessages world, camera
  drawStatusLine world, camera
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

drawMap = (world, camera) ->
  # find the view frustum in camera space
  frustum = translatePtoL DISPLAY_SIZE, camera

  # draw each of the rooms
  ents = world.find "room"
  for ent in ents
    {glyph, room} = ent
    # don't draw rooms we can't see
    continue if room.z isnt camera.z
    continue if room.x2 < frustum.x1
    continue if room.y2 < frustum.y1
    continue if room.x1 > frustum.x2
    continue if room.y1 > frustum.y2
    # draw the room
    for y in [room.y1..room.y2]
      for x in [room.x1..room.x2]
        px = x-frustum.x1
        py = y-frustum.y1
        display.draw px, py, glyph.ch, glyph.fg, glyph.bg

  # draw each of the corridors
  ents = world.find "corridor"
  for ent in ents
    {corridor, glyph} = ent
    # don't draw corridors that we can't see
    continue if corridor.z isnt camera.z
    continue if corridor.x2 < frustum.x1
    continue if corridor.y2 < frustum.y1
    continue if corridor.x1 > frustum.x2
    continue if corridor.y1 > frustum.y2
    # draw the corridor
    for y in [corridor.y1..corridor.y2]
      for x in [corridor.x1..corridor.x2]
        px = x-frustum.x1
        py = y-frustum.y1
        display.draw px, py, glyph.ch, glyph.fg, glyph.bg

  # draw each of the doors
  ents = world.find "door"
  for ent in ents
    {door, glyph} = ent
    # don't draw corridors that we can't see
    continue if door.z isnt camera.z
    continue if door.x < frustum.x1
    continue if door.y < frustum.y1
    continue if door.x > frustum.x2
    continue if door.y > frustum.y2
    # draw the door
    px = door.x-frustum.x1
    py = door.y-frustum.y1
    display.draw px, py, glyph.ch, glyph.fg, glyph.bg

drawMessages = (world, camera) ->
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

drawObjects = (world, camera) ->
  # find the view frustum in camera space
  frustum = translatePtoL DISPLAY_SIZE, camera
  # find everything that we can draw
  ents = world.find [ "glyph", "position" ]
  # TODO: may need to sort these ents by fine-Z value (painter's algorithm)
  for ent in ents
    {glyph, position} = ent
    continue if position.z isnt camera.z
    # draw everything that we can draw
    px = position.x-frustum.x1
    py = position.y-frustum.y1
    display.draw px, py, glyph.ch, glyph.fg, glyph.bg

drawStatusLine = (world, camera) ->
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
  display.drawText 1, STATUS_Y, "%b{#777}%c{#000}Level #{posZ} - X:#{posX} Y:#{posY}"

getCamera = ->
  player = helper.getPlayer()
  return
    x: player.position.x
    y: player.position.y
    z: player.position.z

translatePtoL = (dispSize, camera) ->
  # define the frustum to be the size of the display
  frustum =
    x1: 0
    y1: 0
    x2: dispSize.WIDTH-1
    y2: dispSize.HEIGHT-1
  # translate the upper left corner of the frustum onto the camera
  frustum.x1 += camera.x
  frustum.y1 += camera.y
  frustum.x2 += camera.x
  frustum.y2 += camera.y
  # translate the frustum up and left to center the camera
  frustum.x1 -= dispSize.WIDTH >> 1
  frustum.y1 -= dispSize.HEIGHT >> 1
  frustum.x2 -= dispSize.WIDTH >> 1
  frustum.y2 -= dispSize.HEIGHT >> 1
  # return the coordinates to the caller
  return frustum

class exports.DrawingSystem extends System
  run: -> act @world

# unit testing
exports.translatePtoL = translatePtoL

#----------------------------------------------------------------------
# end of DrawingSystem.coffee
