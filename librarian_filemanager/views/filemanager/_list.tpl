<%!
    # Mapping between MIME type and icon class
    ICON_MAPPINGS = {
        'text/x-python': 'file-xml',
        'text/html': 'file-text-image',
        'text/plain': 'file-text',
        'image/png': 'file-image',
        'image/jpeg': 'file-image',
    }
    DEFAULT_ICON = 'file'
%>

<%def name="file_list_icon(icon_name)">
    ## The icon portion of the file strip
    <span class="file-list-icon icon icon-${icon_name}"></span>
</%def>

<%def name="file_list_name()">
    ## The name portion of the file strip
    <span class="file-list-name">
        ${caller.body()}
    </span>
</%def>

<ul class="file-list ${'search' if is_search else ''}" id="file-list" role="grid" aria-multiselectable="true">
    ## The first item is:
    ##
    ## - Blank if current path is top-level and there is no search query
    ## - Link to complete file list if there is search query
    ## - Link to parent directory if no search query and not at top-level

    % if is_search:
        <li class="file-list-top file-list-item file-list-special">
        <a href="${i18n_url('files:path', path='')}" class="file-list-link" data-type="directory">
            ${self.file_list_icon('folder-left')}
            <%self:file_list_name>
                ## Translators, label for a link that takes the user to
                ## main file/folder list from search results.
                ${_('Go to complete file list')}
            </%self:file_list_name>
        </a>
        </li>
    % elif path != '.':
        <li class="file-list-top file-list-item file-list-special">
        <% uppath = '' if up == '.' else up + '/'%>
        <a href="${i18n_url('files:path', path=up)}" class="file-list-link" data-type="directory">
            ${self.file_list_icon('folder-up')}
            <%self:file_list_name>
                ## Translators, label for a link that takes the user up
                ## one level in folder hierarchy.
                ${_('Go up one level')}
            </%self:file_list_name>
        </a>
        </li>
    % endif

    ## *** FOLDER LISTING ***

    % if (not dirs) and (not files):

        ## If the listing is empty, then only the empty listing li is shown
        <li class="file-list-empty file-list-item">
        <span class="note">
            ${_('There are currently no files or folders here.')}
        </span>
        </li>

    % else:

        ## Directories

        % for d in dirs:
            <%
            dpath = i18n_url('files:path', path=d.rel_path)
            custom_icon = d.dirinfo.get(request.locale, 'icon', None)
            name = d.dirinfo.get(request.locale, 'name', d.name)
            if custom_icon:
                icon_url = i18n_url('files:direct', path=d.other_path(custom_icon))
            else:
                icon_url = None
            description = d.dirinfo.get(request.locale, 'description', None)
            %>
            <li class="file-list-item file-list-directory" role="row" aria-selected="false" tabindex>
            <a
                href="${dpath}"
                data-action-url="${dpath}"
                data-opener="${d.openers_url}"
                data-type="directory"
                class="file-list-link"
                >
                % if icon_url:
                    <span class="file-list-icon file-list-custom-icon">
                        ## Deliberately not supplying alt
                        <img src="${icon_url}">
                    </span>
                % else:
                    ${self.file_list_icon('folder')}
                % endif
                <%self:file_list_name>
                    % if icon_url:
                        <span class="icon icon-folder"></span>
                    % endif
                    <span>${name}</span>
                </%self:file_list_name>
                % if description:
                    <span class="file-list-description">
                        ${description}
                    </span>
                % endif
            </a>
            </li>
        % endfor

        ## Files

        % for f in files:
            <li class="file-list-item file-list-file" role="row" aria-selected="false" tabindex>
            <%
            fpath = i18n_url('files:direct', path=f.rel_path)
            apath = i18n_url('files:path', path=f.rel_path)
            list_openers_url = i18n_url('opener:list') + h.set_qparam(path=f.rel_path).to_qs()
            parent_url = th.get_parent_url(f.rel_path)
            %>
            ## FIXME: fpath doesn't lead to download, what's the download URL?
            <a
                href="${fpath}"
                data-action-url="${apath}"
                data-opener="${list_openers_url}"
                data-mimetype="${f.mimetype or ''}"
                data-type="file"
                class="file-list-link"
                >
                ${self.file_list_icon(ICON_MAPPINGS.get(f.mimetype, DEFAULT_ICON))}
                <%self:file_list_name>
                    ${h.to_unicode(f.name)}
                </%self:file_list_name>
            </a>
            % if is_search:
            <a
                href="${parent_url}"
                data-action-url="${parent_url}"
                data-type="directory"
                class="file-list-link"
                >
                <span>(${_('jump to parent folder')})</span>
            </a>
            % endif
            </li>
        % endfor
    % endif
</ul>
