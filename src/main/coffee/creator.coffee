# creator.coffee
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

{Glyph} = require "./comp/Glyph"
{Player} = require "./comp/Player"
{Position} = require "./comp/Position"

exports.create = (world) ->
  # create our protagonist
  ent = world.createEntity()
  player = new Player "Fred Bloggs"
  world.addComponent ent, "player", player
  glyph = new Glyph "@"
  world.addComponent ent, "glyph", glyph
  position = new Position 40, 12
  world.addComponent ent, "position", position

#----------------------------------------------------------------------
# end of creator.coffee
