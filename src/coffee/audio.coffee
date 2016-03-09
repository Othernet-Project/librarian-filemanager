((window, $, templates) ->
  'use strict'


  playNext = (e) ->
    player = e.data
    next = ($ '.playlist-list-item-current').next '.playlist-list-item'
    if next.length
      player.playlist.next()
      player.player.play()
    return


  class MusicPlayer extends MediaPlayer
    constructor: (container) ->
      features = {
        toggleSidebarOnSelect: false
      }
      super container, features

    onReady: () =>
      @controls = @container.find('#audio-controls-audio').first()
      @controls.mediaelementplayer {
        features: ['playpause', 'progress', 'duration', 'volume'],
        success: (mediaElement) =>
          @onPlayerReady mediaElement
          return
        error: () =>
          @controls.prepend templates.audioLoadFailure
          return

      }
      return


  prepareAudio = () ->
    controls = $ '#audio-controls'
    if not controls.length
      return
    player = new MusicPlayer $ "#views-container"
    ($ player.player).on 'ended', player, playNext
    ($ '#audio-controls-albumart').on 'click', (e) ->
      e.preventDefault()
      if player.player.paused
        player.player.play()
      else
        player.player.pause()
      return
    ($ window).on 'playlist-updated', () ->
      trackInfo = ($ '.playlist-list-item-current').data()
      title = trackInfo.title
      artist = trackInfo.author or trackInfo.artist or template.unknownAuthor
      ($ '#audio-controls-title h2').text title
      ($ '#audio-controls-title p').text artist
    return

  $ prepareAudio
  window.onTabChange prepareAudio

  return
) this, this.jQuery, this.templates
