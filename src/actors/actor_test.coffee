actor_module_setup = ->
    me.loader.preload(App.prototype.g_resources)
    me.game.init(config.ac.screen.width, config.ac.screen.height)
    me.game.addHUD(0, 1, 2, 3, "#000000")
