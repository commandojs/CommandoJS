Enemy = Actor.extend(
    KILL_SCORE: 0

    init: (x, y, settings) ->
        @parent(x, y, settings)
        @type = me.game.ENEMY_OBJECT

    onViewportExit: (clipping) ->
        if clipping.y > 0
            me.game.remove(this)

    onEntityCollision: (coll_vec, entity) ->
        if (entity instanceof Ammunition) and (entity.owner.name == 'hero')
            @setVelocity(0, 0)
            @next_state = 'stateDying'
            the_hero.score.update(@KILL_SCORE)
)
