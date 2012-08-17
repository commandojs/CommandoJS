module 'Utils'

test 'Compare flat arrays', 2, ->
    arr1 = [1, 2, 3]
    arr2 = [1, 2, 3]
    arr3 = [2, 3]
    ok Utils.compareArraysShallow(arr1, arr2)
    ok not Utils.compareArraysShallow(arr1, arr3)

test 'Parse number', 3, ->
    equal Utils.parseNumber('80', 0), 80
    equal Utils.parseNumber('foo', 80), 80
    equal Utils.parseNumber('80.2', 0), 80

test 'Copy objects', 2, ->
    a = { b: 1, c: 4}
    b = Utils.copyObjectShallow(a)
    equal a.b, b.b
    equal a.c, b.c

test 'Sec to tics', 1, ->
    equal Utils.sec2ticks(2), me.sys.fps * 2

test 'Assert', 2, ->
    throws((-> assert(false, 'my message')), Utils.AssertException)
    ok (-> assert(true, 'my message'); true)()


StateTestObj1 = Object.extend(
    state: null
    next_state: null
    result: null
    
    init: ->
        @result = []

    stateIdle:
        onUpdate: ->
            @result.push('stateIdle.onUpdate')
        onExit: ->
            @result.push('stateIdle.onExit')
    
    stateRun:
        onEnter: ->
            @result.push('stateRun.onEnter')
        onUpdate: ->
            @result.push('stateRun.onUpdate')
            @next_state = 'stateDie'
        onExit: ->
            @result.push('stateRun.onExit')
    
    stateDie:
        onEnter: ->
            @result.push('stateDie.onEnter')
)


test 'Basic states', 7, ->
    obj = new StateTestObj1()

    ObjectStateMachine.process(obj)
    deepEqual obj.result, []
    
    obj.next_state = 'stateIdle'
    ObjectStateMachine.process(obj)
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['stateIdle.onUpdate']
    equal obj.next_state, null
    equal obj.state, 'stateIdle'

    obj.result = []
    obj.next_state = 'stateRun'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['stateIdle.onExit', 'stateRun.onEnter']
    
    obj.result = []
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['stateRun.onUpdate']
    
    obj.result = []
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['stateRun.onExit', 'stateDie.onEnter']


HiearachicalStateTestObj1 = Object.extend(
    state: null
    next_state: null
    result: null

    init: ->
        @result = []

    active:
        onEnter: ->
            @result.push('active.onEnter')
        onUpdate: ->
            @result.push('active.onUpdate')
        onExit: ->
            @result.push('active.onExit')

        idle:
            onEnter: ->
                @result.push('active.idle.onEnter')
            onUpdate: ->
                @result.push('active.idle.onUpdate')
            onExit: ->
                @result.push('active.idle.onExit')

        run:
            onEnter: ->
                @result.push('active.run.onEnter')
            onUpdate: ->
                @result.push('active.run.onUpdate')
            onExit: ->
                @result.push('active.run.onExit')

    dead:
        onEnter: ->
            @result.push('dead.onEnter')

)

test 'Hierarchical states', 6, ->
    obj = new HiearachicalStateTestObj1()

    obj.next_state = 'active.idle'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.onEnter', 'active.idle.onEnter']

    obj.result = []
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.onUpdate', 'active.idle.onUpdate']

    obj.result = []
    obj.next_state = 'active.run'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.idle.onExit', 'active.onUpdate', 'active.run.onEnter']

    obj.result = []
    obj.next_state = 'active'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.run.onExit', 'active.onUpdate']

    obj.result = []
    obj.next_state = 'active.run'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.onUpdate', 'active.run.onEnter']

    obj.result = []
    obj.next_state = 'dead'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.run.onExit', 'active.onExit', 'dead.onEnter']


HiearachicalStateTestObj2 = HiearachicalStateTestObj1.extend(
    active:
        onEnter: ->
            @result.push('active.onEnter2')
            @parent()
        onUpdate: ->
            @result.push('active.onUpdate2')

        idle:
            onEnter: ->
                @result.push('active.idle.onEnter2')
            onUpdate: ->
                @result.push('active.idle.onUpdate2')
                @parent()

)

HiearachicalStateTestObj3 = HiearachicalStateTestObj2.extend(
    active:
        onEnter: ->
            @result.push('active.onEnter3')
            @parent()
        onUpdate: ->
            @result.push('active.onUpdate3')

        idle:
            onEnter: ->
                @result.push('active.idle.onEnter3')
                @parent()
            onUpdate: ->
                @result.push('active.idle.onUpdate3')
)


test 'Inherited states', 3, ->
    obj = new HiearachicalStateTestObj2()

    obj.next_state = 'active.idle'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.onEnter2', 'active.onEnter', 'active.idle.onEnter2']

    obj.result = []
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.onUpdate2', 'active.idle.onUpdate2', 'active.idle.onUpdate']

    obj.result = []
    obj.next_state = 'active.run'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.idle.onExit', 'active.onUpdate2', 'active.run.onEnter']

test 'Inherited states, three levels', 1, ->
    obj = new HiearachicalStateTestObj3()

    obj.next_state = 'active.idle'
    ObjectStateMachine.process(obj)
    deepEqual obj.result, ['active.onEnter3', 'active.onEnter2', 'active.onEnter',
                           'active.idle.onEnter3', 'active.idle.onEnter2']
