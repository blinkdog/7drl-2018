# audio.coffee
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

SOUNDS = [
  "crash-large",
  "martian-scanner"
]

sfx = {}

loadSound = (name, ext) ->
  return new Promise (resolve, reject) ->
    audioObj = new Audio "sfx/#{name}.#{ext}"
    audioObj.onloadeddata = ->
      console.log "Audio Loaded: #{name}"
      sfx[name] = audioObj
      return resolve name
    audioObj.onerror = ->
      console.log "Audio Load Failed: #{name}"
      return reject name
    audioObj.load()
    setTimeout (-> reject "timeout: #{name}"), 30000

# load the audio resources
exports.loadResources = ->
  loadPromises = []
  if window?.Audio?
    audio = new Audio()
    if audio.canPlayType "audio/ogg"
      loadPromises = (loadSound name, "ogg" for name in SOUNDS)
    else if audio.canPlayType "audio/mp3"
      loadPromises = (loadSound name, "mp3" for name in SOUNDS)
  return Promise.all loadPromises

# list of available sounds
exports.list = SOUNDS

# loop a sound effect
# @param name name of the sound effect to be looped
exports.loop = (name) ->
  if sfx[name]?
    sfx[name].loop = true
    sfx[name].play()

# play a sound effect
# @param name name of the sound effect to be played
exports.play = (name) ->
  if sfx[name]?
    sfx[name].play()

# stop a looping sound effect
# @param name name of the sound effect to be stopped
exports.stop = (name) ->
  if sfx[name]?
    sfx[name].loop = false
    sfx[name].pause()

# stop all sound effects
exports.stopAll = ->
  for name in SOUNDS
    if sfx[name]?
      sfx[name].loop = false
      sfx[name].pause()

# debugging in browser
window.API.audio = exports if window?.API?

#----------------------------------------------------------------------
# end of audio.coffee
