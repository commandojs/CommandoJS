config =
    context:
        active: 'commandojs'
        commandojs:
            file: "resources/levels/level1.tmx"
            screen:
                width: 28 * 12
                height: 200  # scroller
            hud:
                visible: true
        test:
            file: "resources/levels/test.tmx"
            screen:
                width: 28 * 12
                height: 10 * 12
            hud:
                visible: false

    actors:
        escorts:
            velocity:
                x: -0.6
                y: -0.4
            trigger_distance: 80

    debug:
        enabled: true
        statemachine:
            traces:
                enters: true
                exits: true
                updates: false
                classes: []
        generators:
            generate: true

    # ---- helpers ----
    # gets bound with active context
    ac: null

config.ac = config.context[config.context.active]
