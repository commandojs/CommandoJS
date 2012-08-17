the_hero              = null
AMOUNT_OF_GRENADES    = 5
AMOUNT_OF_LIVES       = 5
POINTS_FOR_EXTRA_LIFE = 10000
GRACE_TIME_AFTER_DEAD = 2.0  # secods

SpawnPoint = GameEntity.extend(
    next_state: 'stateActive'
    stateActive:
        onUpdate: ->
            if me.game.viewport.bottom <= @pos.y
                the_hero.setSpawnPoint(@pos.x, @pos.y)
                me.game.remove(this)
)

Hero = Actor.extend(
    animations:
        idle:
            Up:        [2]
            RightUp:   [3]
            Right :    [6]
            RightDown: [9]
            Down :     [12]
            LeftDown:  [15]
            Left :     [18]
            LeftUp:    [21]
            Default:   [0]
        run:
            Up:        [0, 1, 2]
            RightUp:   [3, 4, 5]
            Right :    [6, 7, 8]
            RightDown: [9, 10, 11]
            Down :     [12, 13, 14]
            LeftDown:  [15, 16, 17]
            Left :     [18, 19, 20]
            LeftUp:    [21, 22, 23]
            Default:   [0]
        die:
            Default:   [24, 25, 25]
            Speed:     0.5
        throw:
            Default:   [2, 32]

    invulnerable: false
    in_grace: false
    move_velocity: 1.5
    spawn_pt: null

    score:
        points: 0
        grenades: 0
        lives: 0
        high_score: 0
        reset: (set_high_score) ->
            if set_high_score
                @high_score = @points if @points > @high_score
            @points = 0
            @grenades = AMOUNT_OF_GRENADES
            @lives = AMOUNT_OF_LIVES
        update: (points) ->
            if points
                old_pt = ~~(@points / POINTS_FOR_EXTRA_LIFE)
                @points += points
                new_pt = ~~(@points / POINTS_FOR_EXTRA_LIFE)
                if old_pt < new_pt
                    @lives += 1
                    player?.effect("life_up")  # ? for testing
            me.game.HUD.setItemValue("score", this)

    getKeyboardMovement: ->
        [x, y] = [0, 0]
        y = -@move_velocity if me.input.isKeyPressed('up')
        y = @move_velocity if me.input.isKeyPressed('down')
        x = -@move_velocity if me.input.isKeyPressed('left')
        x = @move_velocity if me.input.isKeyPressed('right')
        [x, y]

    monitorEnvironment: ->
        level_monitor.update()
        @next_state = 'stateVictoryWalking.toCenter' if level_monitor.completed()

    setSpawnPoint: (x, y) ->
        @spawn_pt = new me.Vector2d(x, y)

    stateSpawn:
        onEnter: ->
            @pos.x = @spawn_pt.x
            @pos.y = @spawn_pt.y
            bottom = @pos.y + @height*2
            bottom = me.game.currentLevel.realheight if bottom > me.game.currentLevel.realheight
            me.game.viewport.move(@pos.x, bottom)
            me.game.viewport.setBounds(me.game.viewport.limits.x, bottom)
            @next_state = 'stateActive.idling'

    stateActive:
        onEnter: ->
            @setDirection(DIRECTIONS.Up)

        onUpdate: ->
            [x, y] = @getKeyboardMovement()
            @setVelocity(x, y)
            if @score.grenades > 0 and me.input.keyStatus('throw')
                @next_state = 'stateActive.throwingGrenade'
                return
            return if @state is 'stateActive.throwingGrenade'
            if (x or y)
                @next_state = 'stateActive.running'
                @setDirection(x, y)
            else
                @next_state = 'stateActive.idling'
            @monitorEnvironment()
            @machinegun.fire() if me.input.keyStatus('shoot')
            @parent()

        running:
            onUpdate: ->
                @setAnimation('run')
                # prevent returning back, i.e. lock camera bottom
                me.game.viewport.setBounds(me.game.viewport.limits.x,
                                           me.game.viewport.bottom)

        idling:
            onEnter: ->
                @setAnimation('idle')

        throwingGrenade:
            onEnter: ->
                @direction = DIRECTIONS.Up
                @setAnimation 'throw', ->
                    new Grenade(this, 2.0, 40)
                    player.effect("grenade_fly")
                    @score.grenades -= 1
                    @score.update()
                    @next_state = 'stateActive.running'

    stateVictoryWalking:
        toCenter:
            onEnter: ->
                x = ~~(me.game.viewport.getRect().width / 2)
                @goTo('run', @move_velocity, x, 50)
                player.finale("victory")

            onUpdate: ->
                # TODO: create callback mechanism for this (instead of polling)
                @_move()
                x = ~~(me.game.viewport.getRect().width / 2)
                if (x - 2) < ~~@pos.x < (x + 2)
                    @next_state = 'stateVictoryWalking.toInside'

        toInside:
            onEnter: ->
                @goTo('run', @move_velocity, @pos.x, 0)

            onUpdate: ->
                @_move()
                if ~~@pos.y < 2
                    # TODO: create callback mechanism for this (instead of polling)
                    @next_state = 'stateLevelCompleted'
                    @score.reset(true)
                    updateScoreTweet(@score.high_score, true) if updateScoreTweet

    stateDying:
        onEnter: ->
            @alive = @collidable = false
            @score.lives -= 1 if @score.lives > 0
            @score.update()
            player.effect("death")
            @setAnimation 'die', ->
                @alive = @collidable = true
                if @score.lives == 0
                    player.stop()
                    @next_state = 'stateLevelFailed'
                    if @score.high_score == 0
                        updateScoreTweet(@score.points, false) if updateScoreTweet
                else
                    @next_state = 'stateSpawn'
                    @in_grace = true
                    @flicker Utils.sec2ticks(GRACE_TIME_AFTER_DEAD), ->
                        @in_grace = false
            return

    stateLevelCompleted:
        onEnter: ->
            me.state.change(me.state.RESULT)

    stateLevelFailed:
        onEnter: ->
            me.state.change(me.state.RESULT)

    onMapCollision: (collision) ->
        # Let player move along the collision edges instead of complete stop
        @vel.y = 0 if collision.y
        @vel.x = 0 if collision.x

    onViewportExit: (clipping) ->
        @vel.y = 0 if clipping.y
        @vel.x = 0 if clipping.x

    onEntityCollision: (coll_vec, entity) ->
        if entity.name == 'grenades'
            me.game.remove(entity)
            @score.grenades += 3
            @score.update(1000)
            player.effect("collect")
            return

        if entity.type == me.game.ENEMY_OBJECT and
           not @invulnerable and not @in_grace

            return if entity.name is 'biker'
            return if entity.state and entity.state is 'stateDying'

            @setVelocity(0, 0)
            @next_state = 'stateDying'

            # TODO: consider if this is the right thing to do. Alternatively ammunition
            #   could check itself if collided and set its velocity to 0. However
            #   this easily causes "non flying bullets", since bullet collides with
            #   its shooter for a brief moment when it's shot
            if entity instanceof Ammunition
                entity.next_state = 'stateLand'

    init: (x, y, settings) ->
        @parent(x, y, settings)

        # Hero has superior gun
        @machinegun = new MachineGun(this)
        @machinegun.ammo_velocity = 8.0
        @machinegun.ammo_lifetime = 16
        @machinegun.fire_delay = 10

        # Camera to always follow the hero:
        me.game.viewport.follow(@pos, me.game.viewport.AXIS.BOTH)
        me.game.viewport.setDeadzone(0, 0)
        @updateColRect(8, 8, 14, 10)
        
        # store reference to hero
        the_hero = this

        # show the score for the first time
        @score.reset(false)
        @score.update()

        # Set first spawn point
        @setSpawnPoint(@pos.x, @pos.y)
        @next_state = 'stateSpawn'
)
