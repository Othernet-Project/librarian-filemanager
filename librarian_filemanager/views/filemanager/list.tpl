<%inherit file="/base.tpl"/>
<%namespace name="forms" file="/ui/forms.tpl"/>

<%block name="title">
## Translators, used as page title
${_('Files')}
</%block>

<%block name="extra_head">
<link rel="stylesheet" type="text/css" href="${assets['css/filemanager']}" />
</%block>

<%block name="menubar_panel">
    <form id="files-multisearch" class="o-multisearch o-panel"> 
        <div class="o-panel">
            <label for="p" class="o-multisearch-label">
                ## Translators, used as label for search field, appears before the text box
                ${_('Search in folders:')}
            </label>
        </div>
`       <div class="o-panel">
            ## Translators, used in file search box
            ${forms.text('p', _('Folder path or search keywords'))}
        </div>
        <div class="o-panel">
            ## Translators, used as button in file view address bar
            <button id="files-multisearch-button" type="submit" class="o-multisearch-button">
                <span class="o-multisearch-button-label">${_('Start search')}</span>
                <span class="o-multisearch-button-icon icon"></span>
            </button>
        </div>
    </form>
</%block>

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

<%block name="main">
    <div class="o-main-inner">
        <ul class="file-list" id="file-list" role="grid" aria-multiselectable="true">
            ## The first item is:
            ##
            ## - Blank if current path is top-level and there is no search query
            ## - Link to complete file list if there is search query
            ## - Link to parent directory if no search query and not at top-level

            % if is_search:
                <li class="file-list-top file-list-item file-list-special">
                <a href="${i18n_url('files:list', path='/')}" class="file-list-link">
                    ${self.file_list_icon('folder-multiple')}
                    <%self:file_list_name>
                        ## Translators, label for a link that takes the user to 
                        ## main file/folder list from search results.
                        ${_('Go to complete file list')}
                    </%self:file_list_name>
                </a>
                </li>
            % elif path != '.':
                <li class="file-list-top file-list-item file-list-special">
                <a href="${i18n_url('files:list', path=up)}" class="file-list-link">
                    ${self.file_list_icon('folder-upload')}
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
                    dpath = h.to_unicode(i18n_url('files:path', path=d.rel_path)) 
                    %>
                    <li class="file-list-item file-list-directory" role="row" aria-selected="false" tabindex>
                    <a 
                        href="${dpath}" 
                        data-action-url="${dpath}"
                        data-opener="${d.openers_url}"
                        class="file-list-link"
                        >
                        ${self.file_list_icon('folder')}
                        <%self:file_list_name>
                            ${h.to_unicode(d.name)}
                        </%self:file_list_name>
                    </a>
                    </li>
                % endfor

                ## Files

                % for f in files:
                    <li class="file-list-item file-list-file" role="row" aria-selected="false" tabindex>
                    <% 
                    fpath = h.to_unicode(i18n_url('files:path', path=f.rel_path)) 
                    list_openers_url = h.to_unicode(i18n_url('opener:list') + h.set_qparam(path=f.rel_path).to_qs())
                    %>
                    ## FIXME: fpath doesn't lead to download, what's the download URL?
                    <a 
                        href="${fpath}"
                        data-action-url="${fpath}"
                        data-opener="${list_openers_url}"
                        class="file-list-link"
                        >
                        ${self.file_list_icon('file')}
                        <%self:file_list_name>
                            ${h.to_unicode(f.name)}
                        </%self:file_list_name>
                    </a>
                    </li>
                % endfor
            % endif
        </ul>
    </div>
</%block>

<%block name="extra_body">
    <script type="text/template" id="renameButton">
        <button class="files-rename-button">${_('Rename')}</button>
    </script>

    <script type="text/template" id="renameFormAlt">
        ${h.form('post', _class="files-rename")}
            <input type="text" name="name" value="">
            <button class="confirm primary" name="action" value="rename" type="submit">${_('Save')}</button>
            <button type="button" class="files-rename-cancel">${_('Cancel')}</button>
        </form>
    </script>
</%block>

<%block name="extra_scripts">
    <script type="text/javascript" src="${assets['js/filemanager']}"></script>
</%block>
