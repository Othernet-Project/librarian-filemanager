// Generated by CoffeeScript 1.10.0
(function(window, $, templates) {
  'use strict';
  var gallery, prepareGallery;
  gallery = {
    initialize: function(container) {
      var currentItemClass, options;
      this.currentImage = container.find('.gallery-current-image img').first();
      this.currentImageLabel = container.find('.gallery-image-title').first();
      container.find('#gallery-control-previous').click((function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.previous();
        };
      })(this));
      container.find('#gallery-control-next').click((function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.next();
        };
      })(this));
      currentItemClass = 'gallery-list-item-current';
      options = {
        itemSelector: '#playlist-list .gallery-list-item',
        currentItemClass: currentItemClass,
        currentItemSelector: '.' + currentItemClass,
        toggleSidebarOnSelect: false,
        setCurrent: (function(_this) {
          return function(current, previous) {
            return _this.onSetCurrent(current, previous);
          };
        })(this)
      };
      this.playlist = new Playlist(container, options);
    },
    onSetCurrent: function(current, previous) {
      var image_url, nextUrl, previousUrl, title;
      title = current.data('title');
      image_url = current.data('direct-url');
      this.currentImage.attr({
        'src': image_url,
        'title': title,
        'alt': title
      });
      this.currentImageLabel.html(title);
      previousUrl = previous.data('url');
      nextUrl = current.data('url');
      if (previousUrl !== nextUrl) {
        window.changeLocation(nextUrl);
      }
    },
    next: function() {
      this.playlist.next();
    },
    previous: function() {
      this.playlist.previous();
    }
  };
  prepareGallery = function() {
    var galleryContainer;
    galleryContainer = $('#views-container');
    if (!galleryContainer.length) {
      return;
    }
    gallery.initialize(galleryContainer);
  };
  $(prepareGallery);
  window.onTabChange(prepareGallery);
})(this, this.jQuery);
