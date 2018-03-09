# story.coffee
# Copyright 2018 Patrick Meade
#----------------------------------------------------------------------

{STATION_SIZE} = require "./config"

exports.COMMAND_LIST = """
  ?                         View Help (**YOU ARE HERE**)
  ESC, Q, X                 Exit Special Modes
  Up, Down, Left, Right     Move
  A                         Attack Selected Target
  L                         Look Mode
  M                         Review Messages Log
  T                         Enter Targeting Mode
  U                         Use Lift
  Enter, Space              Select Target
"""

exports.PLOT_SYNOPSIS = """
  A research station is under attack by alien forces. Humanity's
  only hope is a lone cargo handler down on Level #{STATION_SIZE.LEVELS} when the
  assault began. Fight your way upward to Level 1 and destroy the
  alien ship. Use your resources wisely, you'll need them!
"""

exports.TITLE = "Space Station TDA616"

#----------------------------------------------------------------------
# end of story.coffee
