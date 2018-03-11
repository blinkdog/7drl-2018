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

## Double down on fine-grained attributes
Some of the helper stuff could probably be simplified with
attributes like "BlocksMovement", "BlocksLineOfSight",
"StandingInDoorway", "StandingOnLift", "StandingNextToDoor",
"BottomFloor", "TopFloor", etc...

## Consistency in fine-grained attributes
Why Camera has its own set of x,y,z instead of being a
marker interface for an entity that also has a Position?
Bah... the folly of youth.

## Entity vs Property
The code is pretty picky when it comes to passing an
entity or the specific property. It might be nice to
have a "you know what I meant, pick the thing you
want to examine from the entity that I just passed you"

## Looking Back
When this 7DRL started, I was picking out sound effects.
Now I'm removing them from this commit. I don't have
enough time to flesh out the audio system, and other
features are more compelling.

It's a good thing I followed the Roguebasin 15 step guide
this time around.

## Entity sorting
This is a component that I missed early on; if I would
have given things a "height", it would have been easy to
z-sort them for the display routines.

Closed doors would have full height, open doors would
have zero height.

Yes, this would have been much better than the scattered
one-off functions around the codebase.

## Implicit entity sorting
This looks to be kind of a nasty problem in ECS design.
I've got a bunch of item entities, but what is the
canonical way they should be ordered? And where does
that code go, maybe into helper?

Because I'm running out of time, the canonical ordering
is in the drawing system, and it updates the game state
so that my input handling routines can operate on the
proper item.

An ugly hack; it's got to have a better solution.

## Understanding Node.js EventEmitter
This shows up in the console.

  MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 "component-added" listeners added. Use emitter.setMaxListeners() to increase limit.
  MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 "component-removed" listeners added. Use emitter.setMaxListeners() to increase limit.
  MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 "entity-removed" listeners added. Use emitter.setMaxListeners() to increase limit.

This isn't a hard limit though.

## index-ecs returning internal arrays?
Do I need to slice them before returning them?
Yes, it would appear that I do need to do this.

## LOL
While searching for High Explosives to test, I used the look
mode to scan around and look at the items. Once, I saw a giraffe
and wondered, "WTF is a giraffe doing on this space station?"
