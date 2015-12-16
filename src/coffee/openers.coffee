((window, $) ->
  AUTOCLICK_DELAY = 1500  # 500ms

  openers = $ '.opener a'
  modalOverlay = openers.parents '.o-modal-overlay'
  genericOpener = $ '.opener-generic'


  sendOpenerEvent = (opener) ->
    path = opener.data 'path'
    type = opener.data 'type'
    ($ window).trigger 'opener-click', [{path: path, type: type}]
    return


  openers.on 'click', () ->
    modalOverlay.trigger 'click'
    el = $ this
    sendOpenerEvent el
    return


  if openers.length is 1
    genericOpener[0].click()

  return

) this, this.jQuery
