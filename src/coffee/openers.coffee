((window, $) ->
  AUTOCLICK_DELAY = 500  # 500ms

  openers = $ '.opener'
  modalOverlay = openers.parents '.o-modal-overlay'
  genericOpener = $ '.opener-generic'

  closeOverlay = () ->
    modalOverlay.trigger 'click'

  sendOpenerEvent = (opener) ->
    path = opener.data 'path'
    type = opener.data 'type'
    ($ window).trigger 'opener-click', [{path: path, type: type}]

  openers.on 'click', () ->
    el = $ this
    sendOpenerEvent el

  if openers.length is 1
    url = genericOpener.attr 'href'
    sendOpenerEvent genericOpener
    closeOverlay()
    # jQuery prevents programmatic clicks on links
    setTimeout () ->
      window.location = url
    , AUTOCLICK_DELAY
  else


) this, this.jQuery
