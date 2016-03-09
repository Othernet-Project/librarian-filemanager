((window, $, templates) ->
  'use strict'

  UP = 38
  DOWN = 40
  openerLinkSelector = '.opener-link'
  searchInput = $ '#files-multisearch #p'
  body = $ document.body
  mainPanel = $ "##{window.o.pageVars.mainPanelId}"
  modalDialogTemplate = window.templates.modalDialogCancelOnly
  spinnerIcon = window.templates.spinnerIcon

  setPath = (path) ->
    if path is '.'
      searchInput.val ''
    else
      searchInput.val path
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
    openerListUrl = elem.data 'opener'
    isDir = elem.data('type') is 'directory'

    if !!openerListUrl
      e.preventDefault()
      e.stopPropagation()
      res = $.modalContent openerListUrl, successTemplate: modalDialogTemplate
      res.done (data) ->
        links = $ openerLinkSelector
        links.click (e) ->
          linkEl = $ @
          openerUrl = linkEl.attr 'href'
          $.modalContent openerUrl, fullScreen: true
          e.preventDefault()
          e.stopPropagation()
      return

    if elem.data('type') is 'directory'
      e.preventDefault()
      e.stopPropagation()
      icon = elem.find '.file-list-icon'
      url = elem.attr 'href'

      # Show spinner
      originalIcon = icon.html()
      spinner = $ spinnerIcon
      icon.after spinner
      icon.hide()

      res = loadContent url
      res.done () ->
        window.history.pushState null, null, url
        setPath elem.data 'relpath'
      res.always () ->
        icon.show()
        spinner.remove()

    return

  return
) this, this.jQuery, this.templates
