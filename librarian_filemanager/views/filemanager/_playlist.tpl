<%def name="sidebar_playlist_item(entry, selected_entry)" />

<%def name="sidebar_playlist_item_metadata_desc(entry)">
    %if 'description' in entry:
        <p class="playlist-item-description">
            ${entry.get('description') or _('No description')}
        </p>
    %endif
</%def>

<%def name="sidebar_playlist_item_metadata_author(entry)">
    <p class="playlist-item-author">
        ${entry.get('author') or _('Unknown author') | h}
    </p>
</%def>

<%def name="sidebar_playlist_meta_line(name, label, value)">
    <p class="playlist-item-${name}">
        <span class="label">${label}</span>
        <span class="value">${value | h}</span>
    </p>
</%def>

<%def name="sidebar_playlist_item_metadata_genre(entry)">
    ## Translators, shown for audio files
    ${self.sidebar_playlist_meta_line('genre', _('Genre:'), entry.get('genre') or _('Unknown genre'))}
</%def>

<%def name="sidebar_playlist_item_metadata_album(entry)">
    ## Translators, shown for audio files
    ${self.sidebar_playlist_meta_line('album', _('Album:'), entry.get('album') or _('Unknown album'))}
</%def>

<%def name="sidebar_playlist_item_metadata_duration(entry)">
    ## Translators, used as label for audio/video duration in playlist's info
    ## panel.
    ${self.sidebar_playlist_meta_line('duration', _('Duration:'), durify(entry.get('duration', 0)))}
</%def>

<%def name="sidebar_playlist_video_dimensions(entry)">
    <% 
        # We use min(width, height) here to account for veritcally oriented 
        # videos where width and height is flipped.
        width = entry.get('width', 0)
        height = entry.get('height', 0)
        is_hd = min(width, height) >= 720
    %>

    ## Translators, used as label for video dimensions in playlist's info
    ## panel.
    <p class="playlist-item-dimensions">
        <span class="label">${_('Dimensions:')}</span>
        <span class="value">
            <span>${width} &times; ${height}</span>
            <span class="icon icon-video-${'hd' if is_hd else 'sd'}"></span>
        </span>
    </p>
</%def>

<%def name="sidebar_playlist_image_dimensions(entry)">
    <%
        width = entry.get('width', 0)
        height = entry.get('height', 0)
        mpx = round(width * height / 1000000.0, 1)
    %>
    <p class="playlist-item-dimensions">
        ## Translators, used as label for image dimensions in playlist's info 
        ## panel.
        <span class="label">${_('Dimensions:')}</span>
        <span class="value">
            ${width} &times; ${height} (${mpx} Mpx)
        </span>
    </p>
</%def>

<%def name="sidebar_playlist_aspect_ratio(entry)">
    ## Translators, used as label for image/video aspect ratio (e.g., 4:3,
    ## 16:9) in playlist's info panel.
    ${self.sidebar_playlist_meta_line('aspect', _('Aspect ratio:'), aspectify(entry.get('width', 0), entry.get('height', 0)))}
</%def>

<%def name="sidebar_playlist_item_metadata(entry)">
    ${self.sidebar_playlist_item_metadata_desc(entry)}
    ${self.sidebar_playlist_item_metadata_author(entry)}
</%def>

<%def name="sidebar_playlist_item_details(entry)">
    <h2 class="playlist-item-title">
        ${entry.get('title') or titlify(entry['file']) | h}
    </h2>
    ${self.sidebar_playlist_item_metadata(entry)}
    <p class="playlist-metadata-buttons">
        <a href="${url('files:direct', path=h.urlquote(entry['file_path']))}" class="button" target="_blank">
            <span class="icon icon-download"></span>
            <span class="label">
                ${_('Download')}
            </span>
        </a>
    </p>
</%def>

<%def name="sidebar_playlist(entries, selected_entry)">
    <div class="playlist-section playlist-metadata" id="playlist-metadata">
        ${self.sidebar_playlist_item_details(selected_entry)}
    </div>
    <ul class="playlist-section playlist-list" id="playlist-list" role="grid">
        % for entry in entries:
            ${self.sidebar_playlist_item(entry, selected_entry)}
        % endfor
    </ul>
    <script type="text/template" id="playlistTabs">
        <div class="playlist-tabs">
            <a href="#playlist-list" class="active">
                <span class="icon icon-list"></span>
                <span class="label">
                    ${_('Playlist')}
                </span>
            </a>
            <a href="#playlist-metadata">
                <span class="icon icon-info"></span>
                <span class="label">
                    ${_('Details')}
                </span>
            </a>
        </div>
    </script>
</%def>
