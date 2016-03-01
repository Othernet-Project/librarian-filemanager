((window, $, templates) ->
  'use strict'

  class Gallery
    currentItemClass = 'gallery-list-item-current'

    constructor: (@container) ->
      @currentImage = @container.find('.gallery-current-image-img').first()
      @currentImageLabel = @container.find('#gallery-controls-image-title').first()
      @imagesList = @container.find('#gallery-list .gallery-list-item')
      @currentIndex = 0
      for image, index in @imagesList
        if $(image).hasClass currentItemClass
          @currentIndex = index
          break
      @moveTo(@currentIndex)
      @imagesList.on 'click', 'a', (e) =>
        @onClick(e)
        return

    updateImage: (newIndex) ->
      prevItem = $(@imagesList.get @currentIndex)
      prevItem.removeClass currentItemClass
      @currentIndex = newIndex
      item = $(@imagesList.get @currentIndex)
      item.addClass currentItemClass
      title = item.data('title')
      image_url = item.data('direct-url')
      @currentImage.attr
        'src': image_url
        'title': title
        'alt': title
      @currentImageLabel.html(title)
      return

    updateLocation: () ->
      item = $(@imagesList.get @currentIndex)
      url = item.data('url')
      window.history.pushState null, null, url
      return

    moveTo: (index) ->
      if index < 0 or index >= @imagesList.length
        return
      @updateImage(index)
      @updateLocation()
      return

    next: () ->
      index = (@currentIndex + 1) % @imagesList.length
      @moveTo(index)

    previous: () ->
      index = (@imagesList.length + @currentIndex - 1) % @imagesList.length
      @moveTo(index)

    onClick: (e) ->
      e.preventDefault()
      e.stopPropagation()
      item = $(e.target).closest('li')
      @moveTo(@imagesList.index item)
      return false


  galleryContainer = $ '#gallery-container'
  gallery = new Gallery galleryContainer

  $('#gallery-controls-control-previous').click () ->
    gallery.previous()
    return

  $('#gallery-controls-control-next').click () ->
    gallery.next()
    return

  return
) this, this.jQuery
