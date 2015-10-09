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
      window.history.pushState data, null, url
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
    openerUrl = elem.data 'opener-url'
    isDir = elem.hasClass 'file-list-directory'

    if openerUrl?
      e.preventDefault()
      e.stopPropagation()
      $.modalContent openerUrl, successTemplate: modalDialogTemplate
      return

    if elem.data('type') == 'directory'
      e.preventDefault()
      e.stopPropagation()
      url = elem.attr 'href'
      res = $.get elem.attr 'href'
      res.done (data) ->
        container.html(data)
        window.history.pushState null, null, url
        container.find('a').first().focus()
      res.fail () ->
        alert templates.alertLoadError
      return

  $(window).on 'popstate', (e) ->
    if window.history.state?
      container.html window.history.state
      container.find('a').first().focus()
    else
      url = window.location
      loadContent url


) this, this.jQuery, this.templates
