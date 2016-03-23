<%def name="thumb_block(icon, icon_type='icon')">
    <span class="file-list-icon file-list-icon-${icon_type}">
    % if icon_type in ['cover', 'thumb']:
        <span style="background-image: url('${icon}');"></span>
    % else:
        <span class="icon icon-${icon}"></span>
    % endif
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

<%def name="file_info_inner()">
    <span class="file-list-info">
        <span class="file-list-info-inner">
            ${caller.body()}
        </span>
    </span>
</%def>

<%def name="folder(d, with_controls=False)">
    <%
    description = d.dirinfo.get(request.locale, 'description', None)
    default_view = d.dirinfo.get(request.locale, 'view', None)
    varg = {'view': default_view} if default_view else {}
    dpath = i18n_url('files:path', path=d.rel_path, **varg)
    cover_url = th.get_folder_cover(d)
    icon, icon_is_url = th.get_folder_icon(d)
    %>
    <li class="file-list-item file-list-directory" role="row" aria-selected="false" tabindex>
        <a href="${dpath}" data-type="directory" class="file-list-link${' with-controls' if with_controls else ''}">
            ## COVER/ICON
            % if cover_url:
                ${self.thumb_block(cover_url, 'cover')}
            % elif icon_is_url:
                ${self.thumb_block(icon, 'thumb')}
            % else:
                ${self.thumb_block(icon, 'icon')}
            % endif
            ## INFO BLOCK
            <%self:file_info_inner>
                ## NAME
                <span class="file-list-name">
                    ${th.get_folder_name(d) | h}
                </span>
                ## DESCRIPTION
                % if description:
                    <span class="file-list-description">
                        ${description | h}
                    </span>
                % endif
            </%self:file_info_inner>
        </a>
        ## CONTROLS
        % if with_controls:
            <span class="file-list-controls">
                % if request.user.is_superuser:
                    ${self.file_delete(d.rel_path)}
                % endif
            </span>
        % endif
    </li>
</%def>

<%def name="file(f, with_controls=False)">
    <%
    fpath = h.quoted_url('files:direct', path=f.rel_path)
    apath = i18n_url('files:path', path=f.rel_path)
    list_openers_url = i18n_url('opener:list') + h.set_qparam(path=f.rel_path).to_qs()
    parent_url = th.get_parent_url(f.rel_path)
    %>
    ## FIXME: fpath doesn't lead to download, what's the download URL?
    <li class="file-list-item file-list-file${' with-controls' if with_controls else ''}" role="row" aria-selected="false" tabindex>
        <a
            href="${fpath}"
            data-action-url="${apath}"
            data-opener="${list_openers_url}"
            data-relpath="${f.rel_path | h.urlquote}"
            data-mimetype="${(f.mimetype or '') | h}"
            data-type="file"
            class="file-list-link${' file-list-search-result' if is_search else ''}"
            >
            ${self.thumb_block(th.get_file_icon(f), 'icon')}
            <%self:file_info_inner>
                <span class="file-list-name">
                    ${h.to_unicode(f.name) | h}
                </span>
            </%self:file_info_inner>
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
                % if request.user.is_superuser:
                    ${self.file_delete(f.rel_path)}
                % endif
            </span>
        % endif
    </li>
</%def>
