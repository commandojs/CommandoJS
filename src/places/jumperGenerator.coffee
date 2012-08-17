JumperGenerator = Generator.extend(
    generate: ->
        obj = new Jumper(@pos.x, @pos.y, {name: 'Jumper'})
        me.game.add(obj, Z_LEVEL_JUMP)
        Utils.sortEntities()
        true
)
