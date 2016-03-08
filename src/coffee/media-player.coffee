((window, $, templates) ->
  'use strict'

  class MediaPlayer

    currentItemClass = 'playlist-list-item-current'
    optionSelectors = {
      itemSelector: '#playlist-list .playlist-list-item',
      currentItemClass: currentItemClass,
      currentItemSelector: '.' + currentItemClass,
    }

    constructor: (@container, features, callbacks) ->
      defaultCallbacks = {
        ready: () =>
          @onReady()
          return
        setCurrent: (current, previous) =>
          @onSetCurrent(current, previous)
          return
      }
      options = $.extend {}, optionSelectors, features, defaultCallbacks, callbacks
      @playlist = new Playlist @container, options
      return

    onReady: () =>
      return

    onPlayerReady: (mediaElement) =>
      @player = mediaElement
      ($ window).on 'views-sidebar-toggled', () =>
        @_sidebarToggled()
        return
      return

    onSetCurrent: (current, previous) ->
      @updatePlayer(current)
      @updateDetails(current)
      previousUrl = previous.data('url')
      nextUrl = current.data('url')
      if previousUrl != nextUrl
        window.changeLocation nextUrl
      return

    updatePlayer: (item) ->
      media_url = item.data('direct-url')
      wasPlaying = not @player.paused
      if wasPlaying
        @player.pause()
      @player.setSrc(media_url)
      if wasPlaying
        @player.play()
      return

    detailUnits = {
      'title': '.playlist-item-title',
      'artist': '.playlist-item-artist',
      'author': '.playlist-item-author',
      'description': '.playlist-item-description'
    }
    updateDetails: (item) ->
      detailsContainer = @container.find('#playlist-item-details').first()
      for unit, selector of detailUnits
        value = item.data unit
        if value
          detailsContainer.find(selector).html(value)
      return

    next: () ->
      @playlist.next()
      return

    previous: () ->
      @playlist.previous()
      return

    _sidebarToggled: () ->
      # Hack to get mediaelementjs to resize its controls
      @_triggerResizeEvents 100, 1000
      return

    _triggerResizeEvents: (interval, duration) ->
      ###
      Trigger window resize event every `interval` milliseconds for
      `duration` milliseconds
      ###
      if @_resizeTimerId
        window.clearInterval(@_resizeTimerId)
      start = Date.now()
      end = start + duration
      resizeFunc = () ->
        $(window).trigger 'resize'
        if Date.now() >= end
          window.clearInterval(@_resizeTimerId)
        return
      resizeFunc = resizeFunc.bind(@)
      @_resizeTimerId = window.setInterval resizeFunc, 100
      return

  window.MediaPlayer = MediaPlayer
) this, this.jQuery, this.templates
