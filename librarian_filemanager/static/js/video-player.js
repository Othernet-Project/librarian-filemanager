// Generated by CoffeeScript 1.10.0
(function(window, $, templates) {
  'use strict';
  var VideoPlayer, prepareVideo;
  VideoPlayer = (function() {
    function VideoPlayer(container) {
      var options;
      this.container = container;
      options = {
        itemSelector: '#clips-list .clips-list-item',
        currentItemSelector: '.clips-list-item-current',
        ready: (function(_this) {
          return function() {
            _this.onReady();
          };
        })(this),
        setCurrent: (function(_this) {
          return function(item) {
            _this.onSetCurrent(item);
          };
        })(this)
      };
      this.playlist = new Playlist(this.container, options);
      return;
    }

    VideoPlayer.prototype.onReady = function() {
      this.controls = this.container.find('#video-controls-video').first();
      return this.controls.mediaelementplayer({
        features: ['prevtrack', 'playpause', 'nexttrack', 'progress', 'duration', 'volume', 'fullscreen'],
        success: (function(_this) {
          return function(mediaElement) {
            _this.onPlayerReady(mediaElement);
          };
        })(this),
        error: (function(_this) {
          return function() {
            _this.controls.prepend(templates.videoLoadFailure);
          };
        })(this)
      });
    };

    VideoPlayer.prototype.onPlayerReady = function(mediaElement) {
      this.player = mediaElement;
    };

    VideoPlayer.prototype.onSetCurrent = function(item) {
      this.updatePlayer(item);
      window.changeLocation(item.data('url'));
    };

    VideoPlayer.prototype.updatePlayer = function(item) {
      var height, ref, videoUrl, wasPlaying, width;
      videoUrl = item.data('direct-url');
      ref = [item.data('width'), item.data('height')], width = ref[0], height = ref[1];
      wasPlaying = !this.player.paused;
      if (wasPlaying) {
        this.player.pause();
      }
      this.player.setSrc(videoUrl);
      this.player.setVideoSize(width, height);
      this.player.play();
    };

    return VideoPlayer;

  })();
  prepareVideo = function() {
    var clipsControls, player;
    clipsControls = $('#clips-controls');
    if (!clipsControls.length) {
      return;
    }
    player = new VideoPlayer($('#views-container'));
  };
  prepareVideo();
  window.onTabChange(prepareVideo);
})(this, this.jQuery, this.templates);
