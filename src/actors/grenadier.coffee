Grenadier = Sniper.extend(
    grenade_type: GRENADE_TYPE_LAUNCHER
    amount_of_grenades: 10
    aim:
        RightDown: [58]
        Down:      [58]
        LeftDown:  [58]
    throw:
        RightDown: [58]
        Down:      [58]
        LeftDown:  [58]

    init: (x, y, settings) ->
        # Duplicate animations to allow overriding
        @animations = Utils.copyObjectShallow(@animations)
        @animations['aim'] = @aim
        @animations['throw'] = @throw
        @parent(x, y, settings)

    stateActive:
        attack:
            onEnter: ->
                if @aiming and @amount_of_grenades >= 1
                    @next_state = 'stateActive.attack.throwGrenade'
                else
                    @grenade_type = GRENADE_TYPE_NORMAL
                    @parent()
)
