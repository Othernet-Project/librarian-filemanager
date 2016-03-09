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

% if not facets or not facets.has_type('audio'):
    <span class="note">${_('No music files to be played.')}</span>
% else:
    <%
    audio_facet = facets['audio']
    if audio_facet['cover']:
        cover_path = th.join(audio_facet['path'], audio_facet['cover'])
        cover_url = h.quoted_url('files:direct', path=cover_path)
    else:
        cover_url = assets.url + 'img/albumart-placeholder.png'
    entries = audio_facet['playlist']
    selected_entry = get_selected(entries, selected)
    audio_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
    %>
    <div class="audio-controls" id="audio-controls">
        <div class="audio-controls-albumart" id="audio-controls-albumart">
            <img src="${cover_url}" class="audio-controls-cover">
            <div class="audio-controls-title" id="audio-controls-title">
                <h2>${selected_entry['title']}</h2>
                <p>${selected_entry.get('author', selected_entry.get('artist')) or _('Unknown author')}</p>
            </div>
        </div>
        ${audio_control(audio_url)}
    </div>
% endif

<%def name="sidebar()">
    % if facets and facets.has_type('audio'):
        <%
        entries = facets['audio']['playlist']
        selected_entry = get_selected(entries, selected)
        %>
        ${self.sidebar_playlist(entries, selected_entry)}
    % endif
</%def>

<%def name="sidebar_playlist_item(entry, selected_entry)">
    <%
    file = entry['file']
    current = entry['file'] == selected_entry['file']
    file_path = entry['file_path']
    url = i18n_url('files:path', view=view, path=path, selected=file)
    direct_url = h.quoted_url('files:direct', path=file_path)
    title = entry['title'] or titlify(file)
    artist = entry['artist'] or _('Unknown')
    duration = entry['duration']
    hduration = durify(duration)
    %>
    <li
        class="playlist-list-item ${'playlist-list-item-current' if current else ''}"
        role="row"
        aria-selected="false"
        data-title="${title | h}"
        data-artist="${artist | h}"
        data-duration="${duration}"
        data-url="${url}"
        data-direct-url="${direct_url}">
        <a class="playlist-list-item-link" href="${url}">
            <span class="playlist-list-duration">${hduration}</span>
            <span class="playlist-list-title">${title | h} - ${artist | h}</span>
        </a>
    </li>
</%def>
