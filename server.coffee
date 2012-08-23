log = -> console.log.apply console, arguments
paperboy = require("paperboy")
http = require("http")

static_dir = __dirname

port = 5000

server = http.createServer (req, res) ->
  ip = req.connection.remoteAddress

  proute = paperboy.deliver(static_dir, req, res)

  proute.addHeader "X-Powered-By", "Atari"
  proute.before -> log "Request received for " + req.url
  proute.after (statusCode) -> log statusCode + " - " + req.url + " " + ip

  proute.error (statusCode, msg) ->
    log [statusCode, msg, req.url, ip].join(" ")
    res.writeHead statusCode,
      "Content-Type": "text/plain"
    res.end "Error [" + statusCode + "]"

  proute.otherwise (err) ->
    log [404, err, req.url, ip].join(" ")
    res.writeHead 404,
      "Content-Type": "text/plain"
    res.end "Error 404: File not found"

server.listen port

log "paperboy on his round at #{port}"
