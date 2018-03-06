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

{DISPLAY_SIZE, MESSAGE_HEIGHT, WALL} = require "../config"
{COMMAND_LIST, PLOT_SYNOPSIS, TITLE} = require "../story"

helper = require "../helper"

{System} = require "./System"

display = null
draw = {}

act = (world) ->
  # first, ensure that we've got a display
  createDisplay() if not display?
  # determine what we're going to draw
  mode = helper.getGameMode()
  draw[mode]?(world)

draw["Look"] = (world) ->
  # get the position of the camera
  camera = getCamera()
  # draw everything that needs to be drawn
  display.clear()
  #drawDebugPattern()
  drawWalls world, camera
  drawMap world, camera
  drawObjects world, camera
  drawMessages world, camera
  drawStatusLine world, camera
  drawLookDot world, camera
  # return something reasonable to the caller
  return true

draw["Help"] = (world) ->
  # get the position of the camera
  camera = getCamera()
  # draw the help display
  display.clear()
  display.drawText 30, 6, "Space Station TDA616"
  display.drawText 5, 8, PLOT_SYNOPSIS, 70
  display.drawText 36, 13, "COMMANDS"
  display.drawText 5, 15, COMMAND_LIST, 70
  drawMessages world, camera
  drawStatusLine world, camera

draw["Play"] = (world) ->
  # get the position of the camera
  camera = getCamera()
  # draw everything that needs to be drawn
  display.clear()
  #drawDebugPattern()
  drawWalls world, camera
  drawMap world, camera
  drawObjects world, camera
  drawMessages world, camera
  drawStatusLine world, camera
  # return something reasonable to the caller
  return true

#----------------------------------------------------------------------

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

drawLookDot = (world, camera) ->
  frustum = translatePtoL DISPLAY_SIZE, camera
  px = camera.x-frustum.x1
  py = camera.y-frustum.y1
  display.draw px, py, "*", "#0ff", "#000"

drawMap = (world, camera) ->
  # find the view frustum in camera space
  frustum = translatePtoL DISPLAY_SIZE, camera

  # draw each of the rooms
  ents = world.find [ "area", "glyph", "room" ]
  for ent in ents
    {area, glyph} = ent
    # don't draw rooms we can't see
    continue if area.z isnt camera.z
    continue if area.x2 < frustum.x1
    continue if area.y2 < frustum.y1
    continue if area.x1 > frustum.x2
    continue if area.y1 > frustum.y2
    # draw the room
    for y in [area.y1..area.y2]
      for x in [area.x1..area.x2]
        px = x-frustum.x1
        py = y-frustum.y1
        display.draw px, py, glyph.ch, glyph.fg, glyph.bg

  # draw each of the corridors
  ents = world.find [ "area", "corridor", "glyph" ]
  for ent in ents
    {area, glyph} = ent
    # don't draw corridors that we can't see
    continue if area.z isnt camera.z
    continue if area.x2 < frustum.x1
    continue if area.y2 < frustum.y1
    continue if area.x1 > frustum.x2
    continue if area.y1 > frustum.y2
    # draw the corridor
    for y in [area.y1..area.y2]
      for x in [area.x1..area.x2]
        px = x-frustum.x1
        py = y-frustum.y1
        display.draw px, py, glyph.ch, glyph.fg, glyph.bg

  # draw each of the doors
  ents = world.find [ "door", "glyph", "position" ]
  for ent in ents
    {glyph, position} = ent
    # don't draw corridors that we can't see
    continue if position.z isnt camera.z
    continue if position.x < frustum.x1
    continue if position.y < frustum.y1
    continue if position.x > frustum.x2
    continue if position.y > frustum.y2
    # draw the door
    px = position.x-frustum.x1
    py = position.y-frustum.y1
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
  # determine where we're going to draw the status line
  STATUS_Y = DISPLAY_SIZE.HEIGHT-1
  # clear a line for the status display
  clearLine STATUS_Y, "#777"
  # determine where in the world the player is currently situated
  ents = world.find [ "name", "player", "position" ]
  for ent in ents
    {x,y,z} = ent.position
    {name} = ent.name
    # draw some status text
    mode = helper.getGameMode()
    switch mode
      when "Play"
        STATUS_MSG = "%b{#777}%c{#000}[#{name}] Level:#{z} (#{x}, #{y})"
      when "Look"
        observed = helper.getNameAt getCamera()
        STATUS_MSG = "%b{#777}%c{#000}[Look] #{observed}"
      when "Help"
        STATUS_MSG = "%b{#777}%c{#000}[Help] Level:#{z} (#{x}, #{y})"
    display.drawText 0, STATUS_Y, STATUS_MSG
    HELP_MSG = "[?] Help"
    HELP_MSG = "[X] Exit Help" if mode is "Help"
    HELP_MSG = "[X] Exit Look" if mode is "Look"
    display.drawText DISPLAY_SIZE.WIDTH-(HELP_MSG.length+1), STATUS_Y, "%b{#777}%c{#000}#{HELP_MSG}"

drawWalls = (world, camera) ->
  # find the view frustum in camera space
  frustum = translatePtoL DISPLAY_SIZE, camera
  # draw anything with an area
  ents = world.find "area"
  for ent in ents
    {area} = ent
    # don't draw areas that we can't see
    continue if area.z isnt camera.z
    continue if area.x2 < frustum.x1
    continue if area.y2 < frustum.y1
    continue if area.x1 > frustum.x2
    continue if area.y1 > frustum.y2
    # draw the area with an extra border around it
    for y in [area.y1-1..area.y2+1]
      for x in [area.x1-1..area.x2+1]
        px = x-frustum.x1
        py = y-frustum.y1
        display.draw px, py, WALL.GLYPH, WALL.FG, WALL.BG

getCamera = ->
  {camera} = helper.getCamera()
  return camera

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
