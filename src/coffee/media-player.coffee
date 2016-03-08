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
        setCurrent: (item) =>
          @onSetCurrent(item)
          return
      }
      options = $.extend {}, optionSelectors, features, defaultCallbacks, callbacks
      console.log options
      @playlist = new Playlist @container, options
      return

    onReady: () =>
      return

    onPlayerReady: (mediaElement) =>
      @player = mediaElement
      return

    onSetCurrent: (item) ->
      @updatePlayer(item)
      @updateDetails(item)
      window.changeLocation item.data('url')
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

    next: () ->
      @playlist.next()
      return

    previous: () ->
      @playlist.previous()
      return

  window.MediaPlayer = MediaPlayer
) this, this.jQuery, this.templates
