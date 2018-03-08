# PhysicsSystem.coffee
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

{DISPLAY_SIZE, STATION_SIZE} = require "../config"

helper = require "../helper"

{System} = require "./System"

{GameMode} = require "../comp/GameMode"
{Lift} = require "../comp/Lift"

handle = {}

run = (world, engine) ->
  # we'll need to remove these from the world
  removeEntity = []
  # find the player input that we need to process
  ents = world.find "playerInput"
  if ents.length > 1
    console.log "ERROR: Extraneous PlayerInput entities detected"
  for ent in ents
    removeEntity.push ent
    mode = helper.getGameMode()
    handle[mode]?(world, ent.playerInput.event)
  # remove all player input from the world
  for removeMe in removeEntity
    world.removeEntity removeMe

handle[GameMode.HELP] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_Q", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode GameMode.PLAY
    else
      helper.addMessage "Unknown key #{event.vk}: Press ESC or X to exit Help mode."

handle[GameMode.LOOK] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_Q", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode GameMode.PLAY
    else
      handleLook world, event.vk

handle[GameMode.LOSE] = (world, event) ->

handle[GameMode.MESSAGES] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_Q", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode GameMode.PLAY
    else
      handleMessages world, event.vk

handle[GameMode.PLAY] = (world, event) ->
  switch event.vk
    when "VK_SLASH"
      helper.setGameMode GameMode.HELP
    when "VK_L"
      helper.setGameMode GameMode.LOOK
    when "VK_M"
      {messages} = helper.getMessages()
      {log} = messages
      y = Math.max 0, log.length-DISPLAY_SIZE.HEIGHT+2
      helper.setCamera 0, y, 0
      helper.setGameMode GameMode.MESSAGES
    else
      handlePlay world, event.vk

#----------------------------------------------------------------------

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

handleMessages = (world, vk) ->
  {camera} = helper.getCamera()
  {x, y, z} = camera
  {messages} = helper.getMessages()
  {log} = messages
  # modify camera position
  switch vk
    when "VK_UP"
      y = Math.max 0, y-1
    when "VK_DOWN"
      y = Math.min log.length-1, y+1
    when "VK_PAGE_UP"
      y = Math.max 0, y-(DISPLAY_SIZE.HEIGHT>>1)
    when "VK_PAGE_DOWN"
      y = Math.min log.length-1, y+(DISPLAY_SIZE.HEIGHT>>1)
  # set new camera position
  helper.setCamera x, y, z

handlePlay = (world, vk) ->
  ent = helper.getPlayer()
  switch vk
    when "VK_UP", "VK_DOWN", "VK_LEFT", "VK_RIGHT", "VK_SPACE"
      handlePlayMove world, vk, ent
      helper.tick()
    when "VK_U"
      handlePlayUse world, vk, ent
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

handlePlayUse = (world, vk, playerEnt) ->
  # determine the current position
  {x,y,z} = playerEnt.position
  # get the usable things here
  ents = helper.getUsableAt x, y, z
  # if we didn't find anything to use
  if ents.length is 0
    helper.addMessage "There is nothing to use here."
    return false
  # otherwise, let's pick the first thing on the list
  ent = ents[0]
  msg = null
  # if it's a Lift
  if ent.lift?
    # if it's an up-going lift
    if ent.lift.dir is Lift.UP
      liftEnt = helper.getLiftOnLevel z-1, Lift.DOWN
      playerEnt.position.x = liftEnt.position.x
      playerEnt.position.y = liftEnt.position.y
      playerEnt.position.z = liftEnt.position.z
      msg = "You take the Lift up to the next level."
    # if it's an down-going lift
    else if ent.lift.dir is Lift.DOWN
      liftEnt = helper.getLiftOnLevel z+1, Lift.UP
      playerEnt.position.x = liftEnt.position.x
      playerEnt.position.y = liftEnt.position.y
      playerEnt.position.z = liftEnt.position.z
      msg = "You take the Lift down to the previous level."
    # now we're really confused
    else
      msg = "The Lift is broken and cannot be used."
  # otherwise?
  else
    if ent.name?
      msg = "You aren't sure how to use the #{ent.name}."
    else
      msg = "You aren't sure how to use that."
  # update game state
  helper.addMessage msg if msg?

class exports.PhysicsSystem extends System
  act: -> run @world, @engine

#----------------------------------------------------------------------
# end of PhysicsSystem.coffee
