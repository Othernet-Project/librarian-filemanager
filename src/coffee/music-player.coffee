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
    return


  $ prepareAudio
  window.onTabChange prepareAudio

  return
) this, this.jQuery, this.templates
