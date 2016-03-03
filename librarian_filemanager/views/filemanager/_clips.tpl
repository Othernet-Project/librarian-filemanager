<%
DEFAULT_TITLE = _('Untitled')

DEFAULT_ARTIST = _('Unknown')
%>

<%def name="video_control(url, width, height)">
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

<div class='clips-container' id="clips-container">
    % if not facets or not facets.has_type('video'):
    <span class="note">${_('No video files to be played.')}</span>
    % else:
    <%
      entries = facets['video']['clips']
      if selected:
          try:
              selected_entry = filter(lambda e: e['file'] == selected, entries)[0]
          except IndexError:
              selected_entry = entries[0]
      else:
          selected_entry = entries[0]
      video_url = h.quoted_url('files:direct', path=selected_entry['file_path'])
      width = selected_entry['width']
      height = selected_entry['height']
    %>
    <div class="clips-controls" id="clips-controls">
        ${video_control(video_url, width, height)}
    </div>
    <div class="clips-list-container" id="clips-list-container">
        <h2 style="border-bottom: none;">${_('Clips')}</h2>
        <ol class="clips-list" id="clips-list" role="grid">
        % for entry in facets['video']['clips']:
            <%
            file = entry['file']
            current = entry == selected_entry
            file_path = entry['file_path']
            url = h.quoted_url('files:path', view=view, path=path, selected=file)
            direct_url = h.quoted_url('files:direct', path=file_path)
            title = entry['title'] or DEFAULT_TITLE
            duration = entry['duration']
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
                <a class="clips-list-item-link" href="${url}">${(title or file) | h}</a>
          </li>
        % endfor
        </ol>
    </div>
    % endif
</div>
