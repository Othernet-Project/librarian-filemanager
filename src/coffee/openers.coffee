((window, $) ->
  openers = $ '.opener'
  genericOpener = $ '.opener-generic'

  genericOpener.on 'click', () ->
    elem = $ @
    elem.parents('.o-modal-overlay').remove()

  if openers.length is 1
    # jQuery prevents programmatic clicks on links
    genericOpener[0].click()

) this, this.jQuery
