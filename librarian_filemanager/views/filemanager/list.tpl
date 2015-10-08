<%inherit file="/base.tpl"/>
<%namespace name="forms" file="/ui/forms.tpl"/>
<%namespace name="list" file="_list.tpl"/>

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

<%block name="main">
    <div class="o-main-inner">
        ${list.body()}
    </div>
</%block>

<%block name="extra_body">
    <script type="text/template" id="modalDialogCancelOnly">
        <div class="o-modal-overlay" id="modal-dialog-cancel-only">
            <div class="o-modal-window" role="window" id="modal-dialog-cancel-only-window" tabindex>
                <div class="o-modal-content o-modal-panel" role="document" id="modal-panel">
                    <span class="o-modal-spinner">${_('Loading')}<span class="o-modal-spinner-loading-indicator">...</span></span>
                </div>
                <div class="o-modal-dialog-button-bar">
                    <button id="modal-dialog-cancel-only-close" class="o-modal-close" role="button" aria-controls="modal-dialog-cancel-only-window">
                        ## Translators, appears in a pop-up dialog and allows 
                        ## user to cancel a choice of activities.
                        <span class="o-modal-close-label">${_('Cancel')}</span>
                    </button>
                </div>
            </div>
        </div>
    </script>
</%block>

<%block name="extra_scripts">
    <script type="text/javascript" src="${assets['js/filemanager']}"></script>
</%block>
