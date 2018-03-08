# post-mortem.md
Some notes

## Eye on the prize
I got ahead of myself with StationLevelMap, and decided to refer
to this article so I could keep it tightly focused on releasing
a playable RL for 7DRL 2018.

http://www.roguebasin.com/index.php?title=How_to_Write_a_Roguelike_in_15_Steps

Yeah, StationLevelMap got deleted; entities are intended to be
more fine grained than this. Being able to get rooms, corridors,
and doors is nice.

## Browser objects
Are not world entities, trying to make them such is just a painful
extra layer. Stripping that crap away in DisplaySystem for simplicity
was much nicer.

## Destructured Helpers
This turns out to be really nice. If a helper function returns an
entity, then destructuring can pick out all the components that
we want to access.

    {room} = helper.getNearestRoom 0, STATION_SIZE.HEIGHT, STATION_SIZE.LEVELS

## Understanding ECS
One of my goals with 7DRL 2018 was to learn more about design with
Entity-Component-System architecture. This certainly has been a good
learning experience, but the deadline makes rewriting poor component
choices painful at best.

### Payoff
The DrawingSystem was able to create the walls by painting areas
as larger than they were. This turned out to be a pretty great win.

## Understanding ROT
Sigh. ROT gave me corridors with unordered coordinates. ROT gave me
doors that overlap. It is painful to discover these 'features' under
the pressure of the deadline.

## Editor going 100% CPU and non-responsive
Sucks. Really, WTF?

## Understanding index-ecs
Don't remove the component that you searched for; the index is
live and you'll end up with null entities in your iteration.

## Nasty pattern
I have this pattern in my helper twice now:

xxxForEntities
  xxxForPositions
    xxxForCoordinates

It would be nice if I could get some detection going on
so that I can just pass the thing I have and not worry
about writing two extra peeling layers.

## Code in haste, debug at leisure
When testing I attracted the attention of an aggressive
alien and then got into a long corridor. I held down the
key so that I could zip along the corridor, and to my
surprise, I was able to "outrun" the alien by 10+ squares.

This is due to the way the main loop works. It runs and
it processes an input queue. If that input queue has multiple
movement keypresses, then each one is processed. After that,
the alien is awarded a single action, regardless of how many
player keypresses were processed.

This requires a little thoughtful retooling.

## Missing features in ECS
Twice I've coded this pattern:

  for entities with component X
    collect entities
    ... do stuff with entities ...
  for entities in collection
    remove entities

It looks like index-ecs is missing two calls:
- remove all components of type X
- remove all entities having component X
