# index-ecs-cheat-sheet.md

## World API
addComponent(entity, component, data) -> entity
createEntity(id) -> entity
find(components) -> [entity]
findAll() -> [entity]
findById(id) -> entity
remove() -> World
removeComponent(entity, component) -> entity
removeEntity(entity) -> World
size() -> number

## World Events
component-added -> (entity, component)
component-removed -> (entity, component)
entity-created -> (entity)
entity-removed -> (entity)
