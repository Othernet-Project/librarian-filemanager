<%inherit file="base.tpl"/>
<%namespace name='opener' file='${"openers/%s.tpl" % context["opener_id"]}'/>

<%block name="title">
${meta.title if meta else filename}
</%block>

<%block name="extra_head">
<link rel="stylesheet" type="text/css" href="${assets['css/filemanager']}" />
${opener.extra_head()}
</%block>

<%block name="main">
<div class="opener ${opener_id}" data-opener-id="${opener_id}">
    <div class="opener-frame reduced">
        ${opener.opener_display()}
    </div>
    <div class="opener-meta data expanded">
        <div class="inner">
            <div class="toggle"><span class="icon"></span></div>
            <div class="meta-container">
                ${opener.meta_display()}
            </div>
        </div>
    </div>
</div>
</%block>

<%block name="extra_scripts">
<script type="text/javascript" src="${assets['js/filemanager']}"></script>
${opener.extra_scripts()}
</%block>
