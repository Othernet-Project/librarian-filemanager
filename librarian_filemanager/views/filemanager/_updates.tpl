<%namespace name="folder", file="_folder.tpl"/>

<% is_super = request.user.is_superuser %>

<ul class="file-list file-list-updates" id="file-list" role="grid" aria-multiselectable="true">

    ## *** FOLDER LISTING ***

    % if (not dirs) and (not files):

        ## If the listing is empty, then only the empty listing li is shown
        <li class="file-list-empty file-list-item">
        <span class="note">
            ${_('There are no recent files')}
        </span>
        </li>

    % else:
        <% current_date = None %>

        % for f in files:
            % if current_date != f.create_date.date():
                <% current_date = f.create_date.date() %>
                <h3 class="file-list-changelog" role="row" aria-selected="false" tabindex>
                    <span>${th.ago(f.create_date.date(), days_only=True)}</span>
                </h3>
            % endif
            ${folder.file(f, with_controls=True, is_search=True, use_meta=True)}
        % endfor

    % endif
</ul>
