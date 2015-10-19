<%inherit file="base.tpl"/>

<%block name="title">
${meta.title if meta else filename}
</%block>

<%block name="extra_head">
<link rel="stylesheet" type="text/css" href="${assets['css/filemanager']}" />
</%block>

<%block name="main">
<div class="opener ${opener_id}" data-opener-id="${opener_id}">
    <div class="opener-frame reduced">${opener_html}</div>
    <div class="opener-meta data expanded">
        <div class="inner">
            <div class="toggle"><span class="icon"></span></div>
            <div class="meta-container">
                % if meta:
                <div class="content-info">
                    <div class="title">${meta.title}</div>
                    <div class="download-date">${meta.timestamp.date()}</div>
                </div>
                ## Translators, attribution line appearing in the content list
                <p class="attrib">
                % if meta.publisher:
                ${_('%(date)s by %(publisher)s.') % dict(date=meta.timestamp.strftime('%Y-%m-%d'), publisher=meta.publisher)}
                % else:
                ${meta.timestamp.strftime('%Y-%m-%d')}
                % endif
                ${th.readable_license(meta.license)}
                </p>
                % endif
            </div>
        </div>
    </div>
</div>
</%block>

<%block name="extra_scripts">
<script type="text/javascript" src="${assets['js/filemanager']}"></script>
</%block>
