# Area.coffee
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

class exports.Area
  constructor: (@x1, @y1, @x2, @y2, @z) ->
    @x1 = 0 if not @x1?
    @y1 = 0 if not @y1?
    @x2 = 0 if not @x2?
    @y2 = 0 if not @y2?
    @z = 0 if not @z?

#----------------------------------------------------------------------
# end of Area.coffee
