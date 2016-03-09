<%inherit file="_playlist.tpl" />

<div class='gallery-container' id="gallery-container">
    % if not facets or not facets.has_type('image'):
        <span class="note">${_('No images to be shown.')}</span>
    % else:
        <%
            entries = facets['image']['gallery']
            selected_entry = get_selected(entries, selected)
            previous, next = get_adjacent(entries, selected_entry)
            previous_url = i18n_url('files:path', view=view, path=path, selected=previous['file'])
            next_url = i18n_url('files:path', view=view, path=path, selected=next['file'])
            direct_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
            title = selected_entry['title']
        %>
        <h3 class="gallery-image-title" id="gallery-controls-image-title">
            ${title}
        </h3>
        <div class="gallery-current-image" id="gallery-current-image">
            <img class="gallery-current-image-img" src='${direct_url}'/>
        </div>
        <a
            class="gallery-control gallery-control-previous"
            id="gallery-control-previous"
            href="${previous_url}">
            <span class="icon icon-expand-left"></span>
            <span class="label">
                ${_('Previous')}
            </span>
        </a>
        <a
            class="gallery-control gallery-control-next"
            id="gallery-control-next"
            href="${next_url}">
            <span class="icon icon-expand-right"></span>
            <span class="label">
                ${_('Next')}
            </span>
        </a>
    % endif
</div>

<%def name="sidebar()">
    % if facets and facets.has_type('image'):
        <%
            entries = facets['image']['gallery']
            selected_entry = get_selected(entries, selected)
        %>
        ${self.sidebar_playlist(entries, selected_entry)}
    % endif
</%def>

<%def name="sidebar_playlist_item(entry, selected_entry)">
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
        <img class="gallery-list-item-thumbnail" src="${direct_url}" alt="${title}" title="${title}"/>
    </a>
    </li>
</%def>