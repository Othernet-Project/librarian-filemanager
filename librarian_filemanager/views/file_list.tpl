<%inherit file="base.tpl"/>

<%block name="title">
## Translators, used as page title
${_('Files')}
</%block>

<%block name="extra_head">
<link rel="stylesheet" type="text/css" href="${assets['css/filemanager']}" />
</%block>

<div class="h-bar">
    ${h.form('get', _class='location-bar')}
        ## Translators, used as label for search field, appears before the text box
        <label for="q"><span class="icon search">${_('Search files and folders')}</label>
        ## Translators, used in file search box
        <input type="text" name="p" class="search" value="${path if path != '.' else ''}" placeholder="${_('Search files and folders')}">
        ## Translators, used as button in file view address bar
        <button type="submit" class="primary">${_('Search')}</button>
    </form>
</div>

<div class="file-list">
    <h2>
    <span class="section-name">${_('Files')} /</span> ${path if path != '.' else ''}
    </h2>

    <table class="file-list-listing">
        <thead>
            <tr>
                <th>${_('Name')}</th>
                <th></th>
                <th>${_('Size')}</th>
                <th>${_('Actions')}</th>
            </tr>
        </thead>
        <tbody>
            % if path != '.':
            <tr class="up">
                <% uppath = i18n_url('files:path', path=up) %>
                <td class="icon"><a href="${uppath}"><span class="icon"></span></a></td>
                ## Translators, used as label for link that leads to parent directory in file listing
                <td colspan="3"><a href="${uppath}" class="upone">${_('Go up one level')}<a></td>
            </tr>
            % else:
            <tr class="up">
                <td class="icon"><a href="${i18n_url('files:list')}"><span class="icon"></span></a></td>
                ## Translators, used as label for link that leads to file list
                <td colspan="3"><a href="${i18n_url('files:list')}">${_('(go to file list)')}<a></td>
            </tr>
            % endif

            % if (not dirs) and (not files):
            <tr class="empty">
                ## Tanslators, shown in files section when current folder is empty
                <td class="empty" colspan="4">${_('There are currently no files or folders here.')}</td>
            </tr>
            % else:
                % for d in dirs:
                <tr class="dir">
                    <% dpath = h.to_unicode(i18n_url('files:path', path=d['path'])) %>
                    <td class="icon"><a href="${dpath}"><span class="icon"></span></a></td>
                    <td class="name" colspan="2"><a href="${dpath}">${h.to_unicode(d['name'])}</a></td>
                    <td class="actions">
                        ${h.form('post', action=dpath, _class="files-rename")}
                            <input type="text" name="name" value="${h.to_unicode(d['name'])}">
                            <button name="action" value="rename" type="submit">${_('Rename')}</button>
                        </form>
                        ${h.form('get', action=dpath, _class="files-delete")}
                            <button class="delete" value="delete" type="submit">${_('Delete')}</button>
                        </form>
                    </td>
                </tr>
                % endfor
                % for f in files:
                <tr class="file">
                    <% fpath = h.to_unicode(i18n_url('files:path', path=f['path'])) %>
                    <% list_openers_url = h.to_unicode(i18n_url('opener:list') + h.set_qparam(path=f['path']).to_qs()) %>
                    <td class="icon"><a href="${list_openers_url}"><span class="icon"></span></a></td>
                    <td class="name"><a href="${list_openers_url}">${h.to_unicode(f['name'])}</a></td>
                    <td class="size">${h.hsize(f['size'])}</td>
                    <td class="actions">
                        % if f['path'].endswith('.sh'):
                        ${h.form('post', action=fpath, _class="files-run")}
                            ## Translators, label for button in file listing that allows user to run a script
                            <button class="small" name="action" value="exec" type="submit">${_('Run')}</button>
                        </form>
                        % endif
                        ${h.form('post', action=fpath, _class="files-rename")}
                            <input type="text" name="name" value="${h.to_unicode(f['name'])}">
                            <button name="action" value="rename" type="submit">${_('Rename')}</button>
                        </form>
                        ${h.form('get', action=fpath, _class="files-delete")}
                            <button class="danger" value="delete" type="submit">${_('Delete')}</button>
                        </form>
                    </td>
                </tr>
                % endfor
            % endif
        </tbody>
    </table>
</div>

<%block name="script_templates">
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
