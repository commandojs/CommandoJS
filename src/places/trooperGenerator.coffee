TrooperGenerator = Generator.extend(
    _given_z: null

    init: (x, y, settings) ->
        @parent(x, y, settings)
        @_given_z = Utils.parseNumber(@settings.z, the_hero.z)

    numberOfActiveTroopers: ->
        ret = 0
        for tr in me.game.getEntityByName('trooper')
            ret++ if tr.inViewport()
        ret

    generate: ->
        return false if @numberOfActiveTroopers() >= 6
        trooper = new Trooper(@pos.x, @pos.y, {name: 'Trooper'})
        me.game.add(trooper, @_given_z)
        Utils.sortEntities()
        true
)
