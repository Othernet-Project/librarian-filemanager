<div class="gallery-current-image" id="gallery-current-image">
</div>
<div class="gallery-controls" id="gallery-controls">
    <span class="controls-previous" id="gallery-controls-previous"/>
    <h2 class="gallery-controls-image-title" id="gallery-controls-image-title"/>
    <span class="controls-next" id="gallery-controls-next"/>
</div>
<div class="gallery-list-container" id="gallery-list-container">
    <ul class="gallery-list" id="gallery-list" role="grid">
        % if not facets or not facets.has_type('image'):
            <li class="gallery-list-empty gallery-list-item">
                <span class="note">
                    ${facets}
                    ${facets.has_type('gallery')}
                    ${_('No images to be shown.')}
                </span>
            </li>
        % else:
            % for entry in facets['image']['gallery']:
            <li class="gallery-list-item" role="row" aria-selected="false">
                <%
                path = entry['file_path']
                url = h.quoted_url('files:direct', path=path)
                title = entry['title']
                img_width = entry['width']
                img_height = entry['height']
                %>
                <a 
                    class="gallery-list-item-link" 
                    href="${url}"
                    data-title="${title | h}"
                    data-img-width="${img_width}"
                    data-img-height="${img_height}">
                    <img class="gallery-list-item-thumbnail" src="${url}"/>
                </a>
            </li>
            % endfor
        % endif
    </ul>
</div>
