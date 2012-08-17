module 'AnimatedEntity', {
    setup: ->
        me.loader.preload(App.prototype.g_resources)
        @e = new TestEntity()
}

TestEntity = AnimatedEntity.extend(
    animations:
        idle:
            Up:        []
            RightUp:   []
            Right :    []
            RightDown: []
            Down :     []
            LeftDown:  []
            Left :     []
            LeftUp:    []
            Default:   []
            Speed:     1
        run:
            Default:   []
            Speed:     2
)

test 'Directed animation name resolution', 4, ->
    equal @e.directedAnimationName('idle', DIRECTIONS.Up), 'idleUp'
    equal @e.directedAnimationName('idle', DIRECTIONS.RightDown), 'idleRightDown'
    equal @e.directedAnimationName('idle', null), 'idleDefault'
    equal @e.directedAnimationName('run', DIRECTIONS.Down), 'runDefault'

test 'Set velocity', 3, ->
    @e.setVelocity(1, 0)
    equal @e.vel.toString(), 'x:1 y:0'
    @e.setVelocity(0, 1)
    equal @e.vel.toString(), 'x:0 y:1'
    [x, y] = [10, 10]
    @e.setVelocity(10, 10)
    equal @e.vel.toString(), "x:#{MOVE_DIAGONAL_MULTIPLIER * x} y:#{MOVE_DIAGONAL_MULTIPLIER * y}"

test 'Set direction', 3, ->
    @e.setDirection(0, 4)
    deepEqual @e.direction, DIRECTIONS.Down
    @e.setDirection(0.1, -0.4)
    deepEqual @e.direction, DIRECTIONS.RightUp
    [x, y] = DIRECTIONS.Default
    @e.setDirection(x, y)  # check that previous direction isn't changed
    deepEqual @e.direction, DIRECTIONS.RightUp

test 'Set animation',  4, ->
    @e.setDirection(0, 4)
    @e.setAnimation('idle')
    equal @e.animationspeed, me.sys.fps
    equal @e.current.name, 'idleDown'
    @e.setAnimation('run')
    equal @e.animationspeed, me.sys.fps * 2
    equal @e.current.name, 'runDefault'