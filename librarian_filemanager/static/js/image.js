// Generated by CoffeeScript 1.10.0
(function(window, $, templates) {
  'use strict';
  var LEFT_ARROW, RIGHT_ARROW, SPACE, gallery, prepareGallery;
  LEFT_ARROW = 37;
  RIGHT_ARROW = 39;
  SPACE = 32;
  $.fn.relpos = function(x, y) {
    var centerX, centerY, el, elemH, elemW, elemXpos, elemYpos, left, parent, top;
    el = $(this);
    parent = el.parent();
    centerX = parent.outerWidth() / 2;
    centerY = parent.outerHeight() / 2;
    if (el[0].nodeName === 'IMG') {
      elemW = el[0].naturalWidth;
      elemH = el[0].naturalHeight;
    } else {
      elemW = el.outernetWidth();
      elemH = el.outernetHeight();
    }
    elemXpos = x * elemW;
    elemYpos = y * elemH;
    left = centerX - elemXpos;
    top = centerY - elemYpos;
    return el.css({
      left: left + 'px',
      top: top + 'px'
    });
  };
  $.throttled = function(fn, interval) {
    var lastCall;
    if (interval == null) {
      interval = 200;
    }
    lastCall = 0;
    return function() {
      var current;
      current = Date.now();
      if (current - lastCall > interval) {
        lastCall = current;
        return fn.apply(this, [].slice.call(arguments, 0));
      }
    };
  };
  gallery = {
    initialize: function(container) {
      var currentItemClass, options;
      this.container = container;
      this.currentImage = this.container.find('.gallery-current-image img').first();
      this.imageMetadata = $('#playlist-metadata');
      this.prevHandle = $('#gallery-control-previous');
      this.nextHandle = $('#gallery-control-next');
      this.imageFrame = this.currentImage.parent();
      this.imageFrame.on('click', '.zoomable', (function(_this) {
        return function(e) {
          var height, left, pageX, pageY, ref, top, width, xperc, yperc;
          if (_this.currentImage.hasClass('zoomed')) {
            _this.currentImage.removeClass('zoomed');
            _this.prevHandle.show();
            _this.nextHandle.show();
            return;
          }
          _this.prevHandle.hide();
          _this.nextHandle.hide();
          pageX = e.pageX, pageY = e.pageY;
          ref = _this.currentImage.offset(), left = ref.left, top = ref.top;
          width = _this.currentImage.width();
          height = _this.currentImage.height();
          xperc = (pageX - left) / width;
          yperc = (pageY - top) / height;
          _this.currentImage.relpos(xperc, yperc);
          _this.currentImage.addClass('zoomed');
        };
      })(this));
      this.currentImage.parent().on('mousemove', $.throttled((function(_this) {
        return function(e) {
          var containerH, containerW, containerX, containerY, left, pageX, pageY, ref, top, xperc, yperc;
          if (!_this.currentImage.hasClass('zoomed')) {
            return;
          }
          pageX = e.pageX, pageY = e.pageY;
          ref = _this.imageFrame.offset(), left = ref.left, top = ref.top;
          containerW = _this.imageFrame.outerWidth();
          containerH = _this.imageFrame.outerHeight();
          containerX = Math.min(Math.max(pageX - left, 0), containerW);
          containerY = Math.min(Math.max(pageY - top, 0), containerH);
          xperc = containerX / containerW;
          yperc = containerY / containerH;
          _this.currentImage.relpos(xperc, yperc);
        };
      })(this), 50));
      this.prevHandle.on('click', (function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.previous();
        };
      })(this));
      this.nextHandle.on('click', (function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          _this.next();
        };
      })(this));
      this.container.attr('tabindex', -1);
      this.container.focus();
      this.container.on('keydown', (function(_this) {
        return function(e) {
          var ref;
          if ((ref = e.which) === RIGHT_ARROW || ref === SPACE) {
            return _this.next();
          } else if (e.which === LEFT_ARROW) {
            return _this.previous();
          }
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
      this.playlist = new Playlist(this.container, options);
    },
    makeZoomable: function() {
      var frameH, frameW, imageH, imageW, isBig;
      frameW = this.imageFrame.outerWidth();
      frameH = this.imageFrame.outerHeight();
      imageW = this.currentImage[0].naturalWidth;
      imageH = this.currentImage[0].naturalHeight;
      isBig = imageW > frameW || imageH > frameH;
      this.currentImage.toggleClass('zoomable', isBig);
    },
    onSetCurrent: function(current, previous) {
      var imageUrl, metaUrl, nextUrl, previousUrl, title;
      title = current.data('title');
      imageUrl = current.data('direct-url');
      metaUrl = current.data('meta-url');
      this.currentImage.removeClass('zoomed');
      this.currentImage.attr({
        'src': imageUrl,
        'title': title,
        'alt': title
      });
      this.currentImage.on('load', (function(_this) {
        return function() {
          return _this.makeZoomable();
        };
      })(this));
      this.imageMetadata.load(metaUrl);
      previousUrl = previous.data('url');
      nextUrl = current.data('url');
      if (previousUrl !== nextUrl) {
        window.changeLocation(nextUrl);
      }
    },
    next: function() {
      this.playlist.next();
      this.container.focus();
    },
    previous: function() {
      this.playlist.previous();
      this.container.focus();
    }
  };
  prepareGallery = function() {
    var galleryContainer;
    galleryContainer = $('#gallery-container');
    if (!galleryContainer.length) {
      return;
    }
    gallery.initialize($('#views-container'));
  };
  $(prepareGallery);
  window.onTabChange(prepareGallery);
})(this, this.jQuery);
