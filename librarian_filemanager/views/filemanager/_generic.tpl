<%namespace name="folder", file="_folder.tpl"/>

<% is_super = request.user.is_superuser %>

<ul class="file-list" id="file-list" role="grid" aria-multiselectable="true">

    ## *** FOLDER LISTING ***

    % if (not dirs) and (not files):

        ## If the listing is empty, then only the empty listing li is shown
        <li class="file-list-empty file-list-item">
        <span class="note">
            % if is_search:
            ${_('No files or folders match your search keywords.')}
            % else:
            ${_('There are currently no files or folders here.')}
            % endif
        </span>
        </li>

    % else:

        ## Directories

        % for d in dirs:
            ${folder.folder(d, not is_search)}
        % endfor

        ## Files

        % for f in files:
            ${folder.file(f, not is_search)}
        % endfor
    % endif
</ul>
