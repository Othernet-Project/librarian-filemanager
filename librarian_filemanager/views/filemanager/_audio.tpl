<%inherit file="_playlist.tpl" />

<%def name="audio_control(url)">
    <div id="audio-controls-audio-wrapper" class="audio-controls-audio-wrapper">
        <audio id="audio-controls-audio" controls="controls">
            <source src="${url | h}" />
            <object type="application/x-shockwave-flash" data="${assets.url}vendor/mediaelement/flashmediaelement.swf">
                <param name="movie" value="${assets.url}vendor/mediaelement/flashmediaelement.swf" />
                <param name="flashvars" value="controls=true&file=${url | h}" />
            </object>
        </audio>
    </div>
</%def>

<%def name="view_main()">
    % if not facets or not facets.has_type('audio'):
        <span class="note">${_('No music files to be played.')}</span>
    % else:
        <%
        audio_facet = facets['audio']
        entries = audio_facet['playlist']
        selected_entry = get_selected(entries, selected)
        cover = audio_facet.get('cover')
        cover_path = th.join(audio_facet['path'], cover) if cover else None
        thumb_path = th.get_thumb_path(selected_entry['file_path'], default=cover_path)
        if thumb_path:
            cover_url = h.quoted_url('files:direct', path=thumb_path)
            custom_cover = True
        else:
            cover_url = assets.url + 'img/albumart-placeholder.png'
            custom_cover = False

        audio_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
        %>
        <div class="audio-controls" id="audio-controls">
            <div class="audio-controls-albumart" id="audio-controls-albumart">
                <img src="${cover_url}" class="audio-controls-cover${' audio-controls-custom-cover' if custom_cover else ''}">
                <div class="audio-controls-title" id="audio-controls-title">
                    <h2>${selected_entry.get('title', _('Unknown title'))}</h2>
                    <p>${selected_entry.get('author') or _('Unknown author')}</p>
                </div>
            </div>
            ${audio_control(audio_url)}
        </div>
    % endif
</%def>

<%def name="sidebar()">
    % if facets and facets.has_type('audio'):
        <%
        entries = facets['audio']['playlist']
        selected_entry = get_selected(entries, selected)
        %>
        ${self.sidebar_playlist(entries, selected_entry)}
    % endif
</%def>

<%def name="sidebar_playlist_item_metadata(entry)">
    ${self.sidebar_playlist_item_metadata_desc(entry)}
    ${self.sidebar_playlist_item_metadata_author(entry)}
    % if entry['album']:
        ${self.sidebar_playlist_item_metadata_album(entry)}
    % endif
    % if entry['genre']:
        ${self.sidebar_playlist_item_metadata_genre(entry)}
    % endif
    ${self.sidebar_playlist_item_metadata_duration(entry)}
</%def>

<%def name="sidebar_playlist_item(entry, selected_entry)">
    <%
    file = entry['file']
    current = entry['file'] == selected_entry['file']
    file_path = entry['file_path']
    url = i18n_url('files:path', view=view, path=path, selected=file)
    meta_url = i18n_url('files:path', view=view, path=path, info=file)
    direct_url = h.quoted_url('files:direct', path=file_path)
    title = entry.get('title') or titlify(file)
    author = entry.get('author') or _('Unknown Artist')
    duration = entry.get('duration', 0)
    hduration = durify(duration)
    size = entry.get('size', 0)
    %>
    <li
        class="playlist-list-item ${'playlist-list-item-current' if current else ''}"
        role="row"
        aria-selected="false"
        data-title="${title | h}"
        data-author="${author | h}"
        data-duration="${duration}"
        data-url="${url}"
        data-meta-url="${meta_url}"
        data-direct-url="${direct_url}"
        data-file-size="${size}">
        <a class="playlist-list-item-link" href="${url}">
            <span class="playlist-list-duration">${hduration}</span>
            <span class="playlist-list-title">${title | h} - ${author | h}</span>
        </a>
    </li>
</%def>

${self.view_main()}
