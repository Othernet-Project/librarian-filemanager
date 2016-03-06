((window, $, templates) ->
  'use strict'

  class MusicPlayer

    constructor: (@container) ->
      currentItemClass = 'playlist-list-item-current'
      options = {
        itemSelector: '#playlist-list .playlist-list-item',
        currentItemClass: currentItemClass,
        currentItemSelector: '.' + currentItemClass,
        toggleSidebarOnSelect: false,
        ready: () =>
          @onReady()
          return
        setCurrent: (item) =>
          @onSetCurrent(item)
          return
      }
      @playlist = new Playlist @container, options
      return

    onReady: () =>
      @controls = @container.find('#audio-controls-audio').first()
      @controls.mediaelementplayer {
        features: ['prev', 'playpause', 'next', 'progress', 'duration', 'volume'],
        success: (mediaElement) =>
          @onPlayerReady(mediaElement)
          return
        error: () =>
          @controls.prepend templates.audioLoadFailure
          return
      }
      return

    onPlayerReady: (mediaElement) =>
      @player = mediaElement
      $(@player).on 'mep-ext-playprev', () =>
        @previous()
        return

      $(@player).on 'mep-ext-playnext', () =>
        @next()
        return
      return

    onSetCurrent: (item) ->
      @updatePlayer(item)
      window.changeLocation item.data('url')
      return

    updatePlayer: (item) ->
      audio_url = item.data('direct-url')
      wasPlaying = not @player.paused
      if wasPlaying
        @player.pause()
      @player.setSrc(audio_url)
      if wasPlaying
        @player.play()
      return

    next: () ->
      @playlist.next()
      return

    previous: () ->
      @playlist.previous()
      return

  prepareAudio = () ->
    container = $ '#playlist-container'
    if container.length
      player = new MusicPlayer container
    return

  $ prepareAudio
  window.onTabChange prepareAudio

  return
) this, this.jQuery, this.templates
