# InputSystem.coffee
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

{STATION_SIZE} = require "../config"

helper = require "../helper"

{System} = require "./System"

{GameMode} = require "../comp/GameMode"

eventQueue = null
handle = {}

act = (world) ->
  # first, ensure that we've got keyboard handling
  if not eventQueue?
    createEventQueue()
  # determine what we're going to do with input
  mode = helper.getGameMode()
  # now let's check the event queue
  events = eventQueue.filter (x) ->
    return false if x.vk in [ "VK_ALT", "VK_CONTROL", "VK_SHIFT" ]
    return true
  for event in events
    handle[mode]?(world, event)
  # and clear the event queue
  eventQueue = []

handle["Help"] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode "Play"
    else
      helper.addMessage "Unknown key #{event.vk}: Press ESC or X to exit Help mode."

handle["Look"] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode "Play"
    else
      handleLook world, event.vk

handle["Play"] = (world, event) ->
  switch event.vk
    when "VK_SLASH"
      helper.setGameMode "Help"
    when "VK_L"
      helper.setGameMode "Look"
    # TODO: Implement a message log review mode
    # when "VK_M"
    #   helper.setGameMode GameMode.MESSAGE_LOG
    else
      handlePlay world, event.vk

#----------------------------------------------------------------------

createEventQueue = (world) ->
  console.log "Creating Keyboard eventQueue"
  eventQueue = []
  window.addEventListener "keydown", (e) ->
    code = e.keyCode
    vk = "?"
    for name of ROT
      if (ROT[name] is code) and (name.indexOf("VK_") is 0)
        vk = name
    eventQueue.push
      event: "keydown"
      code: code
      vk: vk
    window.API.game.next()
  # return something reasonable to the caller
  return eventQueue

handleLook = (world, vk) ->
  {camera} = helper.getCamera()
  {x, y, z} = camera
  switch vk
    when "VK_UP"
      y = Math.max 0, y-1
    when "VK_DOWN"
      y = Math.min STATION_SIZE.HEIGHT, y+1
    when "VK_LEFT"
      x = Math.max 0, x-1
    when "VK_RIGHT"
      x = Math.min STATION_SIZE.WIDTH, x+1
  helper.setCamera x, y, z

handlePlay = (world, vk) ->
  ent = helper.getPlayer()
  switch vk
    when "VK_UP", "VK_DOWN", "VK_LEFT", "VK_RIGHT", "VK_SPACE"
      handlePlayMove world, vk, ent
      helper.tick()
    else
      helper.addMessage "DEBUG: Unknown key #{vk}"
  helper.setCamera ent.position.x, ent.position.y, ent.position.z

handlePlayMove = (world, vk, ent) ->
  msg = null
  # determine the current position
  {x,y,z} = ent.position
  # compute the destination position
  dx = x
  dy = y
  dz = z
  switch vk
    when "VK_UP"
      dy--
      msg = "You move north."
    when "VK_DOWN"
      dy++
      msg = "You move south."
    when "VK_LEFT"
      dx--
      msg = "You move west."
    when "VK_RIGHT"
      dx++
      msg = "You move east."
    when "VK_SPACE"
      msg = "You pass."
  # is the destination walkable?
  walk = helper.isWalkable dx, dy, dz
  if walk.ok
    ent.position.x = dx
    ent.position.y = dy
    ent.position.z = dz
  else
    if walk.ent?
      if walk.ent.door?
        walk.ent.door.openingAfter = helper.getTick() + 1
        msg = null
      else if walk.ent.obstacle?
        msg = "The obstacle blocks your path."
      else
        msg = "You can't move that way."
    else
      msg = "You can't move through the wall."
  # update game state
  helper.addMessage msg if msg?

class exports.InputSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of InputSystem.coffee
