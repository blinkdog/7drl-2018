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

{System} = require "./System"

{PlayerInput} = require "../comp/PlayerInput"

run = (world, engine) ->
  # define the handler so it can remove itself later
  handleKeyDown = (e) ->
    # cook the event a little bit
    code = e.keyCode
    vk = "?"
    for name of ROT
      if (ROT[name] is code) and (name.indexOf("VK_") is 0)
        vk = name
    # if this isn't just a modifier key
    if not (vk in [ "VK_ALT", "VK_CONTROL", "VK_SHIFT" ])
      # add it to the world as PlayerInput
      ent = world.createEntity()
      world.addComponent ent, "playerInput", new PlayerInput
        event: "keydown"
        code: code
        vk: vk
      # and unlock the engine
      window.removeEventListener "keydown", handleKeyDown
      engine.unlock()

  # wait for the next keypress by the user
  window.addEventListener "keydown", handleKeyDown
  engine.lock()

class exports.InputSystem extends System
  act: -> run @world, @engine

#----------------------------------------------------------------------
# end of InputSystem.coffee
