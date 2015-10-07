((window, $) ->
  'use strict'

  UP = 38
  DOWN = 40
  fileList = $ '#file-list'
  body = $ document.body
  mainPanel = $ "##{window.o.pageVars.mainPanelId}"
  modalDialogTemplate = window.templates.modalDialogCancelOnly

  # Keyboard navigation

  mainPanel.on 'keydown', '.file-list-link', (e) ->
    elem = $ @
    listItem = elem.parents '.file-list-item'

    switch e.which
      when UP
        listItem.prev().find('a').focus()
        e.preventDefault()
      when DOWN
        listItem.next().find('a').focus()
        e.preventDefault()

    return


  # Opener support

  mainPanel.on 'click', (e) ->
    elem = $ @
    openerUrl = elem.data 'opener-url'

    if not openerUrl?
      return

    e.preventDefault()
    e.stopPropagation()

    $.modalContent openerUrl, successTemplate: modalDialogTemplate
    return



) this, this.jQuery
