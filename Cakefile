fs         = require 'fs'
{exec}     = require 'child_process'
util       = require 'util'

APP_NAME = 'commandojs'

appFiles  = [
    'src/config.coffee',
    'src/utils/utils.coffee',
    'src/base/gameEntity.coffee',
    'src/base/animatedEntity.coffee',
    'src/weapons/ammunition.coffee',
    'src/weapons/machinegun.coffee',
    'src/weapons/bullet.coffee',
    'src/weapons/grenade.coffee',
    'src/weapons/grenadebox.coffee',
    'src/places/place.coffee',
    'src/places/generator.coffee',
    'src/places/trooperGenerator.coffee',
    'src/places/jumperGenerator.coffee',
    'src/places/doorTrigger.coffee',
    'src/actors/actor.coffee',
    'src/actors/enemy.coffee',
    'src/actors/trooper.coffee',
    'src/actors/sniper.coffee',
    'src/actors/biker.coffee',
    'src/actors/escort.coffee',
    'src/actors/grenadier.coffee',
    'src/actors/jumper.coffee',
    'src/actors/officer.coffee',
    'src/actors/prisoner.coffee',
    'src/actors/hero.coffee',
    'src/app/score.coffee',
    'src/app/menu.coffee'
    'src/app/app.coffee'
]


testFiles = do ->
    files = []
    for file in appFiles then do (file) ->
        try
            [base, ext] = file.split('.')
            filename = "#{base}_test.#{ext}"
            stats = fs.lstatSync(filename)
            files.push(filename) if stats.isFile()
    files


task 'join', 'Create joined output files', ->
    join = (files, output_name) ->
        allContents = new Array remaining = files.length
        for file, index in files then do (file, index) ->
            fs.readFile file, 'utf8', (err, fileContents) ->
                throw err if err
                allContents[index] = fileContents
                if --remaining is 0 then do ->
                    allContents = allContents.join('\n\n')
                    fs.writeFile "build/#{output_name}.coffee", allContents, 'utf8', (err) ->
                        throw err if err

    join(appFiles, APP_NAME)
    join(testFiles, APP_NAME + '_tests')


task 'build', 'Build application and test files from source files', ->
    build = (input_name) ->
        input_name = input_name + '.coffee'
        exec "coffee --compile --bare build/#{input_name}", (err, stdout, stderr) ->
            if err
                util.log "Error compiling coffee file #{input_name}: #{err}"
            else
                util.log "Done building coffee file #{input_name}"

    exec "rm -rf ./build", ->
        exec "mkdir ./build", ->
            invoke('join')
            build(APP_NAME)
            build(APP_NAME + '_tests')


task 'lint', 'Lint source files with coffeescript linter', ->
    exec "coffeelint -f util/coffeelint.json -r src", (err, stdout, stderr) ->
        util.print "#{stdout}"


task 'watch', 'Watch source files and build changes', ->
    invoke('build')
    util.log "Watching for changes in src"

    allFiles = appFiles.concat(testFiles)
    for file in allFiles then do (file) ->
        fs.watchFile file, (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{file}, building..."
                invoke('build')

task 'pkg', 'Gather deployable resources underneath build directory', ->
    exec "rm -rf ./build/deploy", ->
        exec "mkdir ./build/deploy", ->
            exec "cp index.html ./build/deploy/"
            exec "mkdir ./build/deploy/build", ->
                exec "cp ./build/commandojs.js ./build/deploy/build/"
            exec "mkdir ./build/deploy/lib", ->
                exec "cp ./lib/melonJS-0.9.3.js ./build/deploy/lib/"
            exec "mkdir ./build/deploy/resources", ->
                exec "mkdir ./build/deploy/resources/images", ->
                    exec "cp ./resources/images/*.png ./build/deploy/resources/images/"
                exec "mkdir ./build/deploy/resources/levels", ->
                    exec "cp ./resources/levels/level1.tmx ./build/deploy/resources/levels/"
                exec "mkdir ./build/deploy/resources/sounds", ->
                    exec "cp ./resources/sounds/* ./build/deploy/resources/sounds/", ->
                        util.log "Done packaging"
