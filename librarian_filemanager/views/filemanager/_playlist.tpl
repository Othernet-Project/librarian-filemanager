<%def name="sidebar_playlist_item(entry, selected_entry)" />

<%def name="sidebar_playlist_item_details(entry)">
    %if 'title' in entry:
        <h2 class="playlist-item-title">${entry.get('title') or titlify(entry['file']) | h}</h2>
    %endif
    %if 'description' in entry:
        <p class="playlist-item-description">
            ${entry.get('description') or _('No description')}
        </p>
    %endif
    %if 'author' in entry or 'artist' in entry:
        <p class="playlist-item-author">
            ${entry.get('author', entry.get('artist')) or _('Unknown author') | h}
        </p>
    % else:
        <p class="playist-item-author">
            ${_('Unknown author')}
        </p>
    %endif
    <p class="playlist-metadata-buttons">
        <a href="${url('files:direct', path=entry['file_path'])}" class="button" target="_blank">
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

