<div class='gallery-container' id="gallery-container">
    % if not facets or not facets.has_type('image'):
    <span class="note">${_('No images to be shown.')}</span>
    % else:
    <%
      entries = facets['image']['gallery']
      if selected:
        try:
            selected_entry = filter(lambda e: e['file'] == selected, entries)[0]
        except IndexError:
            selected_entry = entries[0]
      else:
        selected_entry = entries[0]
      direct_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
      title = selected_entry['title']
    %>
    <h3 class="gallery-image-title" id="gallery-controls-image-title">
        ${title}
    </h3>
    <div class="gallery-current-image" id="gallery-current-image">
        <img class="gallery-current-image-img" src='${direct_url}'/>
    </div>
    <a class="gallery-control gallery-control-previous" id="gallery-control-previous">
        <span class="icon icon-expand-left"></span>
        <span class="label">
            ${_('Previous')}
        </span>
    </a>
    <a class="gallery-control gallery-control-next" id="gallery-control-next">
        <span class="icon icon-expand-right"></span>
        <span class="label">
            ${_('Next')}
        </span>
    </a>
    <div class="gallery-list-container" id="gallery-list-container">
        <ul class="gallery-list" id="gallery-list" role="grid">
            % for entry in facets['image']['gallery']:
                <%
                file = entry['file']
                current = entry == selected_entry
                file_path = entry['file_path']
                url = i18n_url('files:path', view=view, path=path, selected=file)
                direct_url = h.quoted_url('files:direct', path=file_path)
                title = entry['title']
                img_width = entry['width']
                img_height = entry['height']
                %>
                <li
                    class="gallery-list-item ${'gallery-list-item-current' if current else ''}"
                    role="row"
                    aria-selected="false"
                    data-title="${title | h}"
                    data-direct-url="${direct_url}"
                    data-url="${url}"
                    data-img-width="${img_width}"
                    data-img-height="${img_height}">
                    <a class="gallery-list-item-link" href="${url}">
                        <img class="gallery-list-item-thumbnail" src="${direct_url}"/>
                    </a>
              </li>
            % endfor
        </ul>
    </div>
    % endif
</div>
