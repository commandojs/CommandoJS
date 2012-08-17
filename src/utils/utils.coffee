# TODO: couldn't get assertion stuff into Utils without compile error, try again
AssertException = (message) ->
    @message = message

AssertException.prototype.toString = ->
    "AssertException: #{@message}"

assert = (exp, message) ->
    if !exp
        throw new AssertException(message)

me.ObjectEntity.prototype.olog = (msg, fn_name) ->
    fn_str = ''
    if fn_name
        fn_str = " <#{fn_name}>"
    console.log "#{@name} [#{@GUID}]#{fn_str}: #{msg}"

log = (msg, fn_name) ->
    fn_str = ''
    if fn_name
        fn_str = '<#{fn_name}>: '
    console.log "#{fn_str}#{msg}"



Utils =
    compareArraysShallow: (arr1, arr2)  ->
        return (arr1.join('') == arr2.join(''))

    parseNumber: (setting, default_value) ->
        return default_value if setting is undefined or not String(setting).isNumeric()
        return parseInt(setting)

    copyObjectShallow: (source) ->
        destination = {}
        for key of source
            destination[key] = source[key]
        return destination

    sec2ticks: (seconds) ->
        me.sys.fps * seconds

    delay: (secs, fn) ->
        # switch parameter order for more fluent definition in coffeescript
        setTimeout(fn, secs * 1000)

    ZYSort: (a, b) ->
        result = b.z - a.z
        if not result
            return ((b.pos && b.pos.y) - (a.pos && a.pos.y)) || 0
        else
            return result

    sortEntities: ->
        me.game.sort_new(Utils.ZYSort)


ObjectStateMachine =
    trace_enters:  false
    trace_exits:   false
    trace_updates: false
    traced_classes: []

    _get_state_method: (cls, statelist, method_name) ->
        parentCls = cls.__proto__
        sobj = cls
        for s in statelist
            sobj = sobj[s]
            if not sobj  # if state cannot be found from given class
                if parentCls  # try to find it from inheritance parent
                    return @_get_state_method(parentCls, statelist, method_name)
                else  # if this was the "inheritance root", we couldn't find it
                    return null
        method = sobj[method_name]
        if not method  # we found the state object, but there wasn't correct method in it
            if parent  # try if we can find it from inheritance parent
                return @_get_state_method(parentCls, statelist, method_name)
            else  # this was the "inheritance root", we coulnd't find it
                return null
        method

    _trace: (root, statelist_str, method_name) ->
        return if not config.debug.enabled

        traced_instance = false
        for cls in ObjectStateMachine.traced_classes
            if root instanceof window[cls]
                traced_instance = true
        return if not traced_instance
        
        if (method_name == 'onEnter' and ObjectStateMachine.trace_enters) or
           (method_name == 'onExit' and ObjectStateMachine.trace_exits) or
           (method_name == 'onUpdate' and ObjectStateMachine.trace_updates)
            root.olog("#{statelist_str}.#{method_name}")

    # call method of a state object.
    # example params: game_obj, ['active', 'idle'], 'onEnter'
    # takes case of parent calls inside the state methods
    _call_state: (root, statelist, method_name) ->
        # TODO: add debug check for invalid states in the statelist

        # cache method to prevent expensive lookups on further iterations
        statelist_str = "#{statelist.join('.')}"
        cached_name = "_sm_#{statelist_str}.#{method_name}"
        method = root[cached_name]
        if method is undefined
            method = @_get_state_method(root, statelist, method_name)
            root[cached_name] = method or null
        if method
            if ObjectStateMachine.traced_classes.length > 0
                ObjectStateMachine._trace(root, statelist_str, method_name)
            # switch meaning of parent for the duration of this call (changes
            # value parent to function, which is the overridden method in super
            # class. Initially parent is just a reference to super class
            old_parent = root.parent
            parent_state_cls = root.__proto__.__proto__
            prev_parent_cls = null
            # TODO: parent lookup would probably also benefit from similar
            #       caching as above
            root.parent = ->
                if parent_state_cls == prev_parent_cls
                    parent_state_cls = parent_state_cls.__proto__
                pmethod = ObjectStateMachine._get_state_method(parent_state_cls,
                    statelist, method_name)
                prev_parent_cls = parent_state_cls
                pmethod.call(root)
            method.call(root)
            root.parent = old_parent  # switch parent back

    # processes object states based on the obj.state and obj.next_state
    # variables
    process: (obj) ->
        if not (obj.state or obj.next_state)
            return
        if obj.state == obj.next_state
            obj.next_state = null
            # Current state does not change, onUpdate will be called

        state      = obj.state?.split('.')
        next_state = obj.next_state?.split('.')

        if next_state
            entering_state = obj.next_state
            if state
                i = state.length - 1
                while i >= 0
                    state_slice = state[0..i]
                    next_state_slice = next_state[0..i--]
                    # if next_state contains same sub-state, skip
                    if Utils.compareArraysShallow(state_slice, next_state_slice)
                        @_call_state(obj, state_slice, 'onUpdate')
                        break
                    @_call_state(obj, state_slice, 'onExit')

            obj.state = entering_state
            if entering_state is obj.next_state
                obj.next_state = null

            [i, state_count] = [0, next_state.length]
            while i < state_count
                next_state_slice = next_state[0..i]
                # if state contains same sub-state, skip
                if state and Utils.compareArraysShallow(next_state_slice, state[0..i])
                    i++
                    continue
                i++
                @_call_state(obj, next_state_slice, 'onEnter')
        else
            if state
                [i, state_count] = [0, state.length]
                while i < state_count
                    @_call_state(obj, state[0..i++], 'onUpdate')
        return  # to prevent coffeescript results generation
