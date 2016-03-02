((window, $, templates) ->
  'use strict'

  mainContainer = $ '#main-container'
  window.mainContainer = mainContainer

  window.loadContent = (url) ->
    res = $.get url
    res.done (data) ->
      mainContainer.html(data)
      mainContainer.find('a').first().focus()
    res.fail () ->
      alert templates.alertLoadError
    return res

  mainContainer.on 'click', '.views-tabs-tab-link', (e) ->
    e.preventDefault()
    e.stopPropagation()

    elem = $ @
    url = elem.attr 'href'
    res = loadContent url
    res.done () ->
      window.history.pushState null, null, url
      window.triggerTabChange()
      return

  window.onTabChange = (func) ->
    window.mainContainer.on 'filemanager:tabchanged', func
    return

  window.triggerTabChange = () ->
    window.mainContainer.trigger('filemanager:tabchanged')
    return

  return
) this, this.jQuery, this.templates

