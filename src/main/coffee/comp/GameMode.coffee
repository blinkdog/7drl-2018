# GameMode.coffee
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

class exports.GameMode
  constructor: (@mode) ->
    @mode = "Play" if not @mode?

  @HELP = "Help"             # looking at the help screen for commands
  @INVENTORY = "Inventory"   # reviewing inventory to drop/take/use items
  @LOOK = "Look"             # using the look command to examine the map
  @LOSE = "Lose"             # the player has lost the game
  @MESSAGES = "Messages"     # reviewing the log of game messages
  @PLAY = "Play"             # taking action as the protagonist
  @TARGET = "Target"         # player is choosing a target
  @WIN = "Win"               # the player has won the game

#----------------------------------------------------------------------
# end of GameMode.coffee
