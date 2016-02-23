<%inherit file="/base.tpl"/>
<%namespace name="ui" file="/ui/widgets.tpl"/>
<%namespace name="forms" file="/ui/forms.tpl"/>
<%namespace name="files" file="_list.tpl"/>
<%namespace name="gallery" file="_gallery.tpl"/>
<%namespace name="playlist" file="_playlist.tpl"/>
<%namespace name="clips" file="_clips.tpl"/>
<%namespace name="html" file="_html.tpl"/>

<%!
# Mappings between facets and view urls
FACET_VIEW_MAPPINGS = (
    ('generic', 'files', 'Browse'),
    ('image', 'gallery', 'Gallery'),
    ('audio', 'playlist', 'Audio'),
    ('video', 'clips', 'Watch'),
    ('read', 'html', 'Read')
)


def get_views(facets):
    result = list()
    if not facets:
        default = FACET_VIEW_MAPPINGS[0]
        result.append((default[1], default[2]))
        return result
    for facet_type, name, label in FACET_VIEW_MAPPINGS:
        if facets.has_type(facet_type):
            result.append((name, label))
    return result
%>

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
        <div class="o-panel">
            ## Translators, used in file search box
            ${forms.text('p', _('Folder path or search keywords'), value=None if is_search else (esc(h.urlunquote(path)) if path != '.' else ''))}
        </div>
        <div class="o-panel">
            <button id="files-multisearch-button" type="submit" class="o-multisearch-button">
                ## Translators, used as button in file view address bar
                <span class="o-multisearch-button-label">${_('Start search')}</span>
                <span class="o-multisearch-button-icon icon"></span>
            </button>
        </div>
    </form>
</%block>

<%block name="main">
    <div class="o-main-inner" id="views-tabs-container">
        <ul id="views-tabs-strip" class="views-tabs-strip" role="tablist">
            % for name, label in get_views(facets):
                <%
                view_url = i18n_url('files:path', path=path, view=name)
                %>
                 <li class="views-tabs-strip-tab" role="tab">
                     <span class="icon view-icon-${name}"></span>
                     <a href="${view_url}">${_(label)}</a>
                 </li>
            % endfor
        </ul>
    </div>
    <div class="o-main-inner" id="file-list-container">
        % for ns in context.namespaces.values():
            % if ns.name == view:
                ${ns.body()}
                <% break %>
            % endif
        % endfor
    </div>
</%block>

<%block name="extra_body">
    <script type="text/template" id="modalDialogCancelOnly">
        <%ui:modal_container id="dialog-cancel-only" close_button_label="_('Close')">
            <div class="o-modal-content o-modal-panel" role="document">
                <span class="o-modal-spinner">${_('Loading')}<span class="o-modal-spinner-loading-indicator">...</span></span>
            </div>
        </%ui:modal_container>
    </script>

    <script type="text/template" id="spinnerIcon">
        <span class="file-list-icon icon icon-spinning-loader"></span>
    </script>

    <script type="text/template" id="alertLoadError">
        ${_('Folder listing could not be loaded. Please try again in a few seconds.')}
    </script>
</%block>

<%block name="extra_scripts">
    <script type="text/javascript" src="${assets['js/filemanager']}"></script>
</%block>
