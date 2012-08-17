module 'Hero', {
    setup: ->
        actor_module_setup()
        @hero = new Hero()
}

test 'Scores', 6, ->
    @hero.score.high_score = 500
    @hero.score.points = 1000
    @hero.score.reset(true)
    equal @hero.score.grenades, AMOUNT_OF_GRENADES
    equal @hero.score.lives, AMOUNT_OF_LIVES
    equal @hero.score.high_score, 1000
    equal @hero.score.points, 0

    @hero.score.update(100)
    equal @hero.score.lives, AMOUNT_OF_LIVES
    @hero.score.update(POINTS_FOR_EXTRA_LIFE)
    equal @hero.score.lives, AMOUNT_OF_LIVES + 1
