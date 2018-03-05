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

_ = require "lodash"
{System} = require "./System"

eventQueue = null

act = (world) ->
  # first, ensure that we've got keyboard handling
  if not eventQueue?
    createEventQueue()
  # now let's check the event queue
  for event in eventQueue
    handleWalk world, event.vk
  # and clear the event queue
  eventQueue = []

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

handleWalk = (world, vk) ->
  ents = world.find [ "player", "position" ]
  for ent in ents
    switch vk
      when "VK_UP"
        ent.position.y = Math.max 0, ent.position.y-1
      when "VK_DOWN"
        ent.position.y = Math.min 24, ent.position.y+1
      when "VK_LEFT"
        ent.position.x = Math.max 0, ent.position.x-1
      when "VK_RIGHT"
        ent.position.x = Math.min 79, ent.position.x+1

class exports.InputSystem extends System
  run: -> act @world

#----------------------------------------------------------------------
# end of InputSystem.coffee
