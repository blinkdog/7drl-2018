# PlayerThinkSystem.coffee
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

{DETONATION_TICKS, DISPLAY_SIZE, STATION_SIZE} = require "../config"

helper = require "../helper"

{System} = require "./System"

{Attacking} = require "../comp/Attacking"
{GameMode} = require "../comp/GameMode"
{Lift} = require "../comp/Lift"
{Position} = require "../comp/Position"
{Target} = require "../comp/Target"

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
    handle[mode](world, ent.playerInput.event)
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
      helper.addMessage "Press ESC or Q or X to exit Help mode."

handle[GameMode.INVENTORY] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_Q", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode GameMode.PLAY
    else
      handleInventory world, event.vk

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
    when "VK_I"
      helper.setCamera 0, 0, 0
      helper.setGameMode GameMode.INVENTORY
    when "VK_L"
      helper.setGameMode GameMode.LOOK
    when "VK_M"
      {messages} = helper.getMessages()
      {log} = messages
      y = Math.max 0, log.length-DISPLAY_SIZE.HEIGHT+2
      helper.setCamera 0, y, 0
      helper.setGameMode GameMode.MESSAGES
    when "VK_SLASH"
      helper.setGameMode GameMode.HELP
    when "VK_T"
      helper.setGameMode GameMode.TARGET
    else
      handlePlay world, event.vk

handle[GameMode.TARGET] = (world, event) ->
  switch event.vk
    when "VK_ESCAPE", "VK_Q", "VK_X"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode GameMode.PLAY
    when "VK_RETURN", "VK_SPACE"
      player = helper.getPlayer()
      {camera} = helper.getCamera()
      ents = helper.getEntsAt camera
      targetEnt = null
      for ent in ents
        if ent.health?
          targetEnt = ent
          break
      if targetEnt?
        world.addComponent player, "target", new Target targetEnt
      else
        world.removeComponent player, "target"
      {position} = helper.getPlayer()
      {x, y, z} = position
      helper.setCamera x, y, z
      helper.setGameMode GameMode.PLAY
    else
      handleLook world, event.vk

handle[GameMode.WIN] = (world, event) ->

#----------------------------------------------------------------------

handleInventory = (world, vk) ->
  {camera} = helper.getCamera()
  {x, y, z} = camera
  # modify camera position
  # HACK: the drawing code does the clamping; ugh
  switch vk
    when "VK_UP"
      y--
    when "VK_DOWN"
      y++
    when "VK_RETURN"
      handleInventoryDropTake world
    when "VK_SPACE", "VK_U"
      handleInventoryUse world
  # set new camera position
  helper.setCamera x, y, z

handleInventoryDropTake = (world) ->
  player = helper.getPlayer()
  {inventory} = player
  {lookingAt} = inventory
  # if we're not looking at anything
  if not lookingAt?
    helper.addMessage "You don't know how to take that."
    return
  # if the item is on the ground
  if lookingAt.position?
    # put the item into the player's inventory
    inventory.items.push lookingAt
    # and remove its position in the world
    world.removeComponent lookingAt, "position"
    # tell the player about it
    helper.addMessage "You take the #{lookingAt.name.name}."
    return
  # otherwise, remove the item from the player's inventory
  inventory.items = inventory.items.filter (x) ->
    return x isnt lookingAt
  # and give it a position in the world
  {x,y,z} = player.position
  itemPosEnt = new Position x, y, z
  world.addComponent lookingAt, "position", itemPosEnt
  # tell the player about it
  helper.addMessage "You drop the #{lookingAt.name.name}."

handleInventoryUse = (world) ->
  player = helper.getPlayer()
  {inventory} = player
  {lookingAt} = inventory
  # if we're not looking at anything
  if not lookingAt?
    helper.addMessage "You don't know how to use that."
    return
  # if we're looking at the High Explosives
  if lookingAt.highExplosives?
    if not lookingAt.highExplosives.detonateAfter?
      # set them to explode
      lookingAt.highExplosives.detonateAfter = helper.getTick() + DETONATION_TICKS
      helper.addMessage "The High Explosives will detonate in #{DETONATION_TICKS} seconds..."
      return
    else
      # remind the player that they've already set them to explode
      helper.addMessage "The High Explosives are already set to explode."
      return
  # otherwise, it's just a red herring
  helper.addMessage "You make a note to put the #{lookingAt.name.name} into the station's Lost and Found."

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
    when "VK_A"
      ok = handlePlayAttack world, vk, ent
      helper.tick() if ok
    when "VK_U"
      handlePlayUse world, vk, ent
      helper.tick()
    # sure would be nice to capture all these movement keys in a single
    # array instead of spreading them out over so many when cases
    when "VK_HOME", "VK_UP", "VK_PAGE_UP", "VK_LEFT", "VK_CLEAR"
      handlePlayMove world, vk, ent
      helper.tick()
    when "VK_RIGHT", "VK_END", "VK_DOWN", "VK_PAGE_DOWN", "VK_SPACE"
      handlePlayMove world, vk, ent
      helper.tick()
    when "VK_NUMPAD7", "VK_NUMPAD8", "VK_NUMPAD9", "VK_NUMPAD4"
      handlePlayMove world, vk, ent
      helper.tick()
    when "VK_NUMPAD5", "VK_NUMPAD6", "VK_NUMPAD1", "VK_NUMPAD2"
      handlePlayMove world, vk, ent
      helper.tick()
    when "VK_NUMPAD3"
      handlePlayMove world, vk, ent
      helper.tick()
  helper.setCamera ent.position.x, ent.position.y, ent.position.z

handlePlayAttack = (world, vk, ent) ->
  # if we don't have a target to attack
  if not ent.target?
    helper.addMessage "You haven't selected a target to attack!"
    return false
  # if the target is already dead
  if ent.target.ent.corpse?
    helper.addMessage "Your target is already dead."
    return false
  # if the target isn't standing next to us
  adajcent = helper.areEntitiesAdjacent ent, ent.target.ent
  if not adajcent
    helper.addMessage "You must move closer in order to attack!"
    return false
  # it's go time, pal!
  world.addComponent ent, "attacking", new Attacking()
  return true

handlePlayMove = (world, vk, ent) ->
  msg = null
  # determine the current position
  {x,y,z} = ent.position
  # compute the destination position
  dx = x
  dy = y
  dz = z
  switch vk
    when "VK_HOME", "VK_NUMPAD7"
      dx--
      dy--
      msg = "You move northwest."
    when "VK_UP", "VK_NUMPAD8"
      dy--
      msg = "You move north."
    when "VK_PAGE_UP", "VK_NUMPAD9"
      dx++
      dy--
      msg = "You move northeast."
    when "VK_LEFT", "VK_NUMPAD4"
      dx--
      msg = "You move west."
    when "VK_CLEAR", "VK_SPACE", "VK_NUMPAD5"
      helper.addMessage "You pass."
      return
    when "VK_RIGHT", "VK_NUMPAD6"
      dx++
      msg = "You move east."
    when "VK_END", "VK_NUMPAD1"
      dx--
      dy++
      msg = "You move southwest."
    when "VK_DOWN", "VK_NUMPAD2"
      dy++
      msg = "You move south."
    when "VK_PAGE_DOWN", "VK_NUMPAD3"
      dx++
      dy++
      msg = "You move southeast."
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
        if walk.ent.name?
          msg = "#{walk.ent.name.name} blocks your path."
        else
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

class exports.PlayerThinkSystem extends System
  act: -> run @world, @engine

#----------------------------------------------------------------------
# end of PlayerThinkSystem.coffee
