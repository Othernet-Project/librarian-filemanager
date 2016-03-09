<%def name="sidebar_playlist_item(entry, selected_entry)" />

<%def name="sidebar_playlist_item_details(entry)">
    %if 'title' in entry:
        <h2 class="playlist-item-title">${entry.get('title') or titlify(entry['file']) | h}</h2>
    %endif
    %for key in ('artist', 'author'):
        %if key in entry:
            <p class="playlist-item-artist">
                ${entry.get(key) or _('Unknown') | h}
            </p>
        %endif
    %endfor
    %if 'description' in entry:
        <p class="playlist-item-description">
            ${entry.get('description') or _('No description')}
        </p>
    %endif
</%def>

<%def name="sidebar_playlist(entries, selected_entry)">
    <div class="playlist-metadata" id="playlist-metadata">
        ${self.sidebar_playlist_item_details(selected_entry)}
    </div>
    <ul class="playlist-list" id="playlist-list" role="grid">
        % for entry in entries:
            ${self.sidebar_playlist_item(entry, selected_entry)}
        % endfor
    </ul>
</%def>
