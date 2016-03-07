<%def name="audio_control(url)">
    <div id="audio-control-wrapper" class="audio-control-wrapper">
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
      entries = facets['audio']['playlist']
      selected_entry = get_selected(entries, selected)
      audio_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
    %>
    <div class="playlist-controls" id="playlist-controls">
        <div class="playlist-controls-albumart" id="playlist-controls-albumart">
            <img src="${cover_url}"/>
        </div>
        ${audio_control(audio_url)}
    </div>
% endif

<%def name="sidebar()">
    <div class="playlist-list-container" id="playlist-list-container">
        <div class="playlist-list-container-meta">
            <ol class="playlist-list" id="playlist-list" role="grid">
            <% selected_entry = get_selected(facets['audio']['playlist'], selected) %>
            % for entry in facets['audio']['playlist']:
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
            % endfor
            </ol>
            <h2>${selected_entry.get('title') or titlify(selected_entry['file']) | h}</h2>
            <p class="audio-artist">
                ${selected_entry.get('artist') or _('Unknown')}
            </p>
        </div>
    </div>
</%def>
