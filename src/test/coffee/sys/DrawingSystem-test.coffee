# DrawingSystem-test.coffee
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

should = require "should"

measure = (view) ->
  return
    width: (view.x2 - view.x1) + 1
    height: (view.y2 - view.y1) + 1

describe "DrawingSystem", ->
  it "should obey the laws of logic", ->
    false.should.equal false
    true.should.equal true

  describe "translatePtoL", ->
    {translatePtoL} = require "../../lib/sys/DrawingSystem"

    it "should give proper coordinates on even dimensions", ->
      DISPLAY =
        WIDTH: 20
        HEIGHT: 20
      CAMERA =
        x: 50
        y: 50
      worldView = translatePtoL DISPLAY, CAMERA
      worldView.should.eql
        x1: 40
        y1: 40
        x2: 59
        y2: 59
      measured = measure worldView
      measured.should.eql
        width: DISPLAY.WIDTH
        height: DISPLAY.HEIGHT

    it "should give proper coordinates on odd dimensions", ->
      DISPLAY =
        WIDTH: 79
        HEIGHT: 25
      CAMERA =
        x: 50
        y: 50
      worldView = translatePtoL DISPLAY, CAMERA
      worldView.should.eql
        x1: 11
        y1: 38
        x2: 89
        y2: 62
      measured = measure worldView
      measured.should.eql
        width: DISPLAY.WIDTH
        height: DISPLAY.HEIGHT

    it "should give proper coordinates on even/odd dimensions", ->
      DISPLAY =
        WIDTH: 80
        HEIGHT: 25
      CAMERA =
        x: 20
        y: 10
      worldView = translatePtoL DISPLAY, CAMERA
      worldView.should.eql
        x1: -20
        y1: -2
        x2: 59
        y2: 22
      measured = measure worldView
      measured.should.eql
        width: DISPLAY.WIDTH
        height: DISPLAY.HEIGHT

#----------------------------------------------------------------------
# end of DrawingSystem-test.coffee
