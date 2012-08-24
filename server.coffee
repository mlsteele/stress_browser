log = -> console.log.apply console, arguments

(require 'zappajs') 5000, ->
  @configure =>
    @set views: "#{__dirname}"
    @set 'view engine': 'jade'
    @set 'view options': {layout: false}
    @use 'bodyParser', 'methodOverride', 'static'
    # @use require('connect-assets')(src: "#{__dirname}")
    # @use 'static'

  @app.get '/', (req,res) ->
    log 'rendering stress'
    res.render 'stress'
    log 'rendered stress'
