// Generated by CoffeeScript 1.10.0
(function(window, $, templates) {
  'use strict';
  var Gallery, prepareGallery;
  Gallery = (function() {
    function Gallery(container, listContainer) {
      var currentItemClass, options;
      this.container = container;
      this.listContainer = listContainer;
      currentItemClass = 'gallery-list-item-current';
      options = {
        itemSelector: '#gallery-list .gallery-list-item',
        currentItemClass: currentItemClass,
        currentItemSelector: '.' + currentItemClass,
        toggleSidebarOnSelect: false,
        ready: (function(_this) {
          return function() {
            _this.onReady();
          };
        })(this),
        setCurrent: (function(_this) {
          return function(current, previous) {
            return _this.onSetCurrent(current, previous);
          };
        })(this)
      };
      this.playlist = new Playlist(this.listContainer, options);
      return;
    }

    Gallery.prototype.onReady = function() {
      this.currentImage = this.container.find('.gallery-current-image img').first();
      this.currentImageLabel = this.container.find('.gallery-image-title').first();
      this.container.find('#gallery-control-previous').click((function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.previous();
        };
      })(this));
      this.container.find('#gallery-control-next').click((function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.next();
        };
      })(this));
    };

    Gallery.prototype.onSetCurrent = function(current, previous) {
      var image_url, nextUrl, previousUrl, title;
      title = item.data('title');
      image_url = item.data('direct-url');
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
    };

    Gallery.prototype.next = function() {
      this.playlist.next();
    };

    Gallery.prototype.previous = function() {
      this.playlist.previous();
    };

    return Gallery;

  })();
  prepareGallery = function() {
    var gallery, galleryContainer, galleryListContainer;
    galleryListContainer = $('#gallery-list-container');
    if (!galleryListContainer.length) {
      return;
    }
    galleryContainer = $('#gallery-container');
    gallery = new Gallery(galleryContainer, galleryListContainer);
  };
  $(prepareGallery);
  window.onTabChange(prepareGallery);
})(this, this.jQuery);
