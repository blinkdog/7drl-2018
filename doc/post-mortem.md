# post-mortem.md
Some notes

## Eye on the prize
I got ahead of myself with StationLevelMap, and decided to refer
to this article so I could keep it tightly focused on releasing
a playable RL for 7DRL 2018.

http://www.roguebasin.com/index.php?title=How_to_Write_a_Roguelike_in_15_Steps

## Browser objects
Are not world entities, trying to make them such is just a painful
extra layer. Stripping that crap away in DisplaySystem for simplicity
was much nicer.
