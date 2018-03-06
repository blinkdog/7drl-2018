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

_ = require "lodash"
{System} = require "./System"
helper = require "../helper"

eventQueue = null
handle = {}

act = (world) ->
  # first, ensure that we've got keyboard handling
  if not eventQueue?
    createEventQueue()
  # determine what we're going to do with input
  mode = helper.getGameMode()
  # now let's check the event queue
  for event in eventQueue
    if not filterEvent event
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

filterEvent = (event) ->
  switch event.vk
    when "VK_ALT", "VK_CTRL", "VK_SHIFT"
      return true
  return false

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
    when "VK_UP"
      ent.position.y = Math.max -50, ent.position.y-1
      helper.addMessage "You walk north."
    when "VK_DOWN"
      ent.position.y = Math.min 100, ent.position.y+1
      helper.addMessage "You walk south."
    when "VK_LEFT"
      ent.position.x = Math.max -50, ent.position.x-1
      helper.addMessage "You walk west."
    when "VK_RIGHT"
      ent.position.x = Math.min 100, ent.position.x+1
      helper.addMessage "You walk east."
    when "VK_ALT", "VK_CTRL", "VK_SHIFT"
    else
      helper.addMessage "DEBUG: Unknown key #{vk}"
  helper.setCamera ent.position.x, ent.position.y, ent.position.z

class exports.InputSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of InputSystem.coffee
