<%inherit file="_sidebar_playlist.tpl" />

<%def name="video_control(url)">
    <div id="video-control-wrapper" class="video-control-wrapper">
        <video id="video-controls-video" controls="controls" width="100%" height="100%" preload="none">
            <source src="${url | h}" />
            <object type="application/x-shockwave-flash" data="${assets.url}vendor/mediaelement/flashmediaelement.swf">
                <param name="movie" value="${assets.url}vendor/mediaelement/flashmediaelement.swf" />
                <param name="flashvars" value="controls=true&file=${url | h}" />
            </object>
        </video>
    </div>
</%def>

% if not facets or not facets.has_type('video'):
<span class="note">${_('No video files to be played.')}</span>
% else:
<%
  entries = facets['video']['clips']
  selected_entry = get_selected(entries, selected)
  video_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
%>
<div class="clips-controls" id="clips-controls">
    ${video_control(video_url)}
</div>
% endif

<%def name="sidebar()">
    %if facets and facets.has_type('video'):
        <%
        entries = facets['video']['clips']
        selected_entry = get_selected(entries, selected)
        %>
        ${self.sidebar_playlist(entries, selected_entry)}
    %endif
</%def>
<%def name="sidebar_playlist_item(entry, selected_entry)">
    <%
        file = entry['file']
        current = entry['file'] == selected_entry['file']
        file_path = entry['file_path']
        url = i18n_url('files:path', view=view, path=path, selected=file)
        direct_url = h.quoted_url('files:direct', path=file_path)
        title = entry['title'] or titlify(entry['file'])
        duration = entry['duration']
        hduration = durify(duration)
        width = entry['width']
        height = entry['height']
    %>
    <li
    class="playlist-list-item ${'playlist-list-item-current' if current else ''}"
    role="row"
    aria-selected="false"
    data-title="${title | h}"
    data-duration="${duration}"
    data-width="${width}"
    data-height="${height}"
    data-url="${url}"
    data-direct-url="${direct_url}">
    <a class="playlist-list-item-link" href="${url}">
        <span class="playlist-list-duration">
            ${hduration}
        </span>
        <span class="playlist-list-title">
            ${title | h}
        </span>
    </a>
    </li>
</%def>
