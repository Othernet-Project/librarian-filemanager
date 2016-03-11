% if not facets or not facets.has_type('html'):
    <span class="note">${_('No documents to be shown.')}</span>
% else:
<%
full_path = '/'.join([facets['html']['path'], facets['html']['index']])
%>
<div class="views-reader">
    <iframe class="views-reader-frame" src="${url('files:direct', path=full_path)}">
</div>
% endif
