log = -> console.log.apply console, arguments
reduce = (list, memo, iterator) -> _.reduce list, iterator, memo

log 'STRESS'

make_touch_draggable = (el, ybounds={min: (-> -Infinity), max: (-> Infinity)}) ->
  $el = $(el)
  tx = 'touch-draggable-last-mouse-x'
  ty = 'touch-draggable-last-mouse-y'
  tdgc = 'touch-draggable-dragging'

  $el.bind 'touchstart', (e) ->
    e.preventDefault()
    e.stopPropagation()
    touch = e.originalEvent.targetTouches[0]

    $el.data tx, touch.clientX
    $el.data ty, touch.clientY

    $el.addClass tdgc

  $el.bind 'touchmove', (e) ->
    e.preventDefault()
    e.stopPropagation()
    touch = e.originalEvent.targetTouches[0]

    newy = parseInt($el.css 'top')  + touch.clientY - $el.data(ty)

    $el.css
      left: parseInt($el.css 'left') + touch.clientX - $el.data(tx)
      top : Math.max(ybounds.min(), Math.min(newy, ybounds.max()))
    # log "current (post) css: " + [($el.css 'left'), ($el.css 'top')]

    $el.data tx, touch.clientX
    $el.data ty, touch.clientY

  $el.bind 'touchend', (e) ->
    $el.removeClass tdgc

$ =>
  indicate = (color) -> $('.indicator').css background: color

  # disable page scrolling
  _.each ['touchstart', 'touchmove'], (evn) -> _.each [document, document.body], (thing) -> thing.addEventListener evn, (e) -> e.preventDefault()

  $('#container').css height: $(document).height()

  make_card_envoy = (card) ->
    $ 'div'
    $div = $ '<div/>',
      class: 'g-entity card'
      text: [null,'A',2,3,4,5,6,7,8,9,10,'J','Q','K'][card.n]
    $div.data 'card', card
    $div.appendTo $ '#container'
    make_touch_draggable $div,
      min: _.memoize -> $('#row2').position().top
      max: -> if card_envoys_on_table().length <= 4
          $('#row2').position().top + $('#row2').height() - 100
        else Infinity
    $div.bind 'touchend', -> attempt_client_hand_close()
    return $div

  ## element placement

  # place enemy hands
  _.each $('.enemy-hand'), (eh, i) ->
    pad = $('#row1').width() - $(eh).width() * 6
    $(eh).css
      left: (pad / 6 + $(eh).width()) * i + pad / 7 / 2
      top: $('#row1').height() / 2 - $(eh).height() / 2

  # place client hands
  _.each $('.client-hand'), (ch, i) ->
    left_offset = 210
    $(ch).css
      left: (i % 3) * ($('#row4').width()/2 - left_offset - $(ch).width()/2) + left_offset
      top: (reduce ['#row1', '#row2', '#row3'], 0, (a, n) -> a + $(n).height()) + 150 + Math.floor(i / 3) * 220

  # make deck
  deck = reduce (_.map [[{n: n, suit: suit} for n in [1..13]] for suit in [0...4]][0], (a) -> a[0]), [], (a,b) -> a.concat b
  log "generated #{deck.length} cards"

  ## initial data fills

  gstate =
    card_envoys_on_surface: []
    open_hand: null

  # place initial table cards
  for i in [0...4]
    $ce = $(make_card_envoy(deck[i]))
    $ce.css
      left: 120 + i * 200
      top: (reduce ['#row1'], 0, (a, n) -> a + $(n).height()) + 110
    gstate.card_envoys_on_surface.push $ce

  # fill client hands
  _.each $('.client-hand'), (h) -> $(h).data('cards', [])
  log "filled empty client hands"
  for i in [4...4 + 24]
    $target_hand = $((_.filter $('.client-hand'), (ch) -> $(ch).data('cards').length < 4)[0])
    $target_hand.data('cards').push deck[i]

  pop_client_hand = (client_hand) ->
    $ch = $(client_hand)
    log "popping client hand of #{[c.n for c in ($ch.data 'cards')]}"
    $ch = $(client_hand)
    gstate.open_hand = $ch
    $ch.addClass 'open'

    # create card envoys
    card_envoys = _.map ($ch.data 'cards'), (card, i) ->
      $ce = $ make_card_envoy card
      center = [$ch.offset().x + $ch.width() / 2, $ch.offset().y + $ch.height() / 2]
      angle_offset = 1.2
      $ce.css
        left: parseInt($ch.css 'left') + $ch.width() / 2 + Math.cos(-Math.PI / 2 - angle_offset + angle_offset * 2 / 3 * i) * 160 - $ce.width() / 2
        top : parseInt($ch.css 'top') + $ch.height() / 2 + Math.sin(-Math.PI / 2 - angle_offset + angle_offset * 2 / 3 * i) * 160 - $ce.height() / 2
      $ce

    # register card envoys
    [gstate.card_envoys_on_surface.push ce for ce in card_envoys]

  card_envoys_in_open_hand = ->
    _.filter gstate.card_envoys_on_surface, (card_envoy) ->
      $ce = $(card_envoy)
      $ce.position().top + $ce.height() / 2 > $('#row2').position().top + $('#row2').height()

  card_envoys_on_table = ->
    _.filter gstate.card_envoys_on_surface, (card_envoy) ->
      $ce = $(card_envoy)
      $ce.position().top + $ce.height() / 2 < $('#row2').position().top + $('#row2').height()


  attempt_client_hand_close = ->
    log "attempting client hand close"
    return true if gstate.open_hand is null
    return false if _.any [[$('.card'), 'touch-draggable-dragging'], [$('.client-hand'), 'touching']], (lc) -> _.any lc[0], (el) -> $(el).hasClass lc[1]
    ceoh = card_envoys_in_open_hand()
    log "card_envoys_in_open_hand #{ceoh.length}"
    return false unless ceoh.length is 4

    log "client close tests passed, closing"
    $(gstate.open_hand).data 'cards', _.map ceoh, (card_envoy) ->
      $ch = $(card_envoy)
      card = $ch.data 'card'
      gstate.card_envoys_on_surface = _.without gstate.card_envoys_on_surface, $ch
      $ch.remove()
      card

    $(gstate.open_hand).removeClass 'open'
    gstate.open_hand = null

  # bind hand listeners
  $('.client-hand').bind 'touchstart', (ev) ->
    $ch = $(ev.target)
    $ch.addClass 'touching'
    return unless gstate.open_hand is null
    pop_client_hand $ch

  $('.client-hand').bind 'touchend', (ev) ->
    $(ev.target).removeClass 'touching'
    attempt_client_hand_close()
