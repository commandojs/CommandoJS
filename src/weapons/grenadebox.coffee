GrenadeBox = AnimatedEntity.extend(
    animations:
        idle:
            Default: [114]
    
    stateWaiting:
        onEnter: ->
            @setAnimation('idle')
)
