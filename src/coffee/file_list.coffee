((window, $, templates) ->
  'use strict'

  UP = 38
  DOWN = 40
  fileList = $ '#file-list'
  container = $ '#file-list-container'
  body = $ document.body
  mainPanel = $ "##{window.o.pageVars.mainPanelId}"
  modalDialogTemplate = window.templates.modalDialogCancelOnly

  loadContent = (url) ->
    res = $.get url
    res.done (data) ->
      container.html(data)
      container.find('a').first().focus()
    res.fail () ->
      alert templates.alertLoadError
    return

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

  mainPanel.on 'click', '.file-list-link', (e) ->
    elem = $ @
    openerUrl = elem.data 'opener'
    isDir = elem.data('type') is 'directory'

    if openerUrl? and not isDir
      e.preventDefault()
      e.stopPropagation()
      $.modalContent openerUrl, successTemplate: modalDialogTemplate
      return

    if elem.data('type') is 'directory'
      e.preventDefault()
      e.stopPropagation()
      url = elem.attr 'href'
      loadContent url
      window.history.pushState null, null, url
      return

    return

  $(window).on 'popstate', (e) ->
    loadContent window.location


) this, this.jQuery, this.templates
