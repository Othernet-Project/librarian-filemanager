<%
DEFAULT_TITLE = _('Untitled')

DEFAULT_ARTIST = _('Unknown')
%>

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
    <div class="clips-list-container" id="clips-list-container">
        <div class="clip-list-container-meta">
            <ul class="clips-list" id="clips-list" role="grid">
                <% selected_entry = get_selected(facets['video']['clips'], selected) %>
                % for entry in facets['video']['clips']:
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
                    class="clips-list-item ${'clips-list-item-current' if current else ''}"
                    role="row"
                    aria-selected="false"
                    data-title="${title | h}"
                    data-duration="${duration}"
                    data-width="${width}"
                    data-height="${height}"
                    data-url="${url}"
                    data-direct-url="${direct_url}">
                    <a class="clips-list-item-link" href="${url}">
                        <span class="clips-list-duration">
                            ${hduration}
                        </span>
                        <span class="clips-list-title">
                            ${title | h}
                        </span>
                    </a>
                    </li>
                % endfor
            </ul>
            <h2>${selected_entry.get('title') or titlify(selected_entry['file']) | h}</h2>
            <p class="clip-author">
                ${selected_entry.get('author') or _('Unkown author')}
            </p>
            <p class="clip-description">
                ${selected_entry.get('description', _('No description'))}
            </p>
        </div>
    </div>
</%def>
