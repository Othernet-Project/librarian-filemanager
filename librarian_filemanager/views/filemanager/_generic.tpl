<%!
    # Mapping between MIME type and icon class
    ICON_MAPPINGS = {
        'text/x-python': 'file-xml',
        'text/html': 'file-text-image',
        'text/plain': 'file-text',
        'image/png': 'file-image',
        'image/jpeg': 'file-image',
    }
    VIEW_ICON_MAPPING = {
        'html': 'html',
        'audio': 'audio',
        'video': 'video',
        'image': 'image',
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

<%def name="file_delete(path)">
    <form action="${i18n_url('files:path', path=path)}" class="file-list-delete file-list-control">
        <input type="hidden" name="action" value="delete">
        <button class="nobutton" type="submit">
            <span class="icon icon-no-outline"></span>
            ## Translators, used as label for folder/file delete button
            <span class="label">${_('Delete')}</span>
        </button>
    </form>
</%def>

<%def name="file_download(path)">
    <a href="${url('files:direct', path=h.urlquote(path))}" class="file-list-control">
        <span class="icon icon-download-outline"></span>
        <span class="label">${_('Download')}</span>
    </a>
</%def>

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
            <%
            # Get basic dirinfo metadata
            name = d.dirinfo.get(request.locale, 'name', d.name)
            description = d.dirinfo.get(request.locale, 'description', None)
            default_view = d.dirinfo.get(request.locale, 'view', None)
            custom_icon = d.dirinfo.get(request.locale, 'icon', None)
            # Set folder icon
            if custom_icon:
                icon_url = h.quoted_url('files:direct', path=d.other_path(custom_icon))
            else:
                icon_url = None
            # Set folder target URL and icon name
            dpath = i18n_url('files:path', path=d.rel_path, view=default_view)
            icon_name = VIEW_ICON_MAPPING.get(default_view, 'folder')
            %>
            <li class="file-list-item file-list-directory" role="row" aria-selected="false" tabindex>
            <a
                href="${dpath}"
                data-action-url="${dpath}"
                data-relpath="${d.rel_path | h.urlquote}"
                data-type="directory"
                class="file-list-link"
                >
                % if icon_url:
                    <span class="file-list-icon file-list-custom-icon">
                        ## Deliberately not supplying alt
                        <img src="${icon_url}">
                    </span>
                % else:
                    ${self.file_list_icon(icon_name)}
                % endif
                <%self:file_list_name>
                    % if icon_url:
                        <span class="icon icon-folder"></span>
                    % endif
                    <span>${name}</span>
                </%self:file_list_name>
                % if description:
                    <span class="file-list-description">
                        ${description | h}
                    </span>
                % endif
            </a>
            % if not is_search:
                <span class="file-list-controls">
                    % if is_super:
                        ${self.file_delete(d.rel_path)}
                    % endif
                </span>
            % endif
            </li>
        % endfor

        ## Files

        % for f in files:
            <li class="file-list-item file-list-file${' file-list-search-result' if is_search else ''}" role="row" aria-selected="false" tabindex>
            <%
            fpath = h.quoted_url('files:direct', path=f.rel_path)
            apath = i18n_url('files:path', path=f.rel_path)
            list_openers_url = i18n_url('opener:list') + h.set_qparam(path=f.rel_path).to_qs()
            parent_url = th.get_parent_url(f.rel_path)
            %>
            ## FIXME: fpath doesn't lead to download, what's the download URL?
            <a
                href="${fpath}"
                data-action-url="${apath}"
                data-opener="${list_openers_url}"
                data-relpath="${f.rel_path | h.urlquote}"
                data-mimetype="${(f.mimetype or '') | h}"
                data-type="file"
                class="file-list-link${' file-list-search-result' if is_search else ''}"
                >
                ${self.file_list_icon(ICON_MAPPINGS.get(f.mimetype, DEFAULT_ICON))}
                <%self:file_list_name>
                    ${h.to_unicode(f.name) | h}
                </%self:file_list_name>
            </a>
            % if is_search:
                <a
                    href="${parent_url}"
                    data-action-url="${parent_url}"
                    data-type="directory"
                    class="file-list-search-result file-list-parent-folder"
                    >
                    <span>
                        <span class="icon icon-folder"></span>
                        <span>
                            ## Translators, link to containing folder of a file
                            ## in the search results. {} is a placeholder for
                            ## the folder name.
                            ${_(u"in {}").format(esc(f.parent))}
                        </span>
                    </span>
                </a>
            % else:
                <span class="file-list-controls">
                    ${self.file_download(f.rel_path)}
                    % if is_super:
                        ${self.file_delete(f.rel_path)}
                    % endif
                </span>
            % endif
            </li>
        % endfor
    % endif
</ul>
