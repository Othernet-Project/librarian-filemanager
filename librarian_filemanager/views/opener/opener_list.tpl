<%inherit file="/base.tpl"/>
<%namespace name='opener_list' file='_opener_list.tpl'/>

<%block name="title">
## Translators, used as page title
${_('Files')}
</%block>

<%block name="extra_head">
<link rel="stylesheet" type="text/css" href="${assets['css/filemanager']}" />
</%block>

${opener_list.body()}
