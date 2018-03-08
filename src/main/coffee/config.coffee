# config.coffee
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

exports.DEBUG =
  # This just hurts the player until they die; don't enable!
  FLOODED_WITH_RADIATION: false
  # all messages are observed, not just the ones in player view
  OMNISCIENT: true

exports.DISPLAY_SIZE =
  WIDTH: 80
  HEIGHT: 30

exports.DOOR =
  CLOSED:
    CH: "Z"
    FG: "#555"
    BG: "#111"
  OPEN:
    CH: "."
    FG: "#777"
    BG: "#000"

exports.DOOR_CLOSE_TICKS = 3

exports.MESSAGE_HEIGHT = 4

w = 80
h = 25
exports.STATION_SIZE =
  WIDTH: w
  HEIGHT: h
  LEVELS: 10
exports.STATION_SIZE.DISTANCE = Math.sqrt((w*w)+(h*h))

exports.WALL =
  GLYPH: " "
  FG: "#777"
  BG: "#111"

exports.NUM_ALIENS = exports.STATION_SIZE.LEVELS*2

exports.NUM_CREW = exports.STATION_SIZE.LEVELS

#----------------------------------------------------------------------
# end of config.coffee
