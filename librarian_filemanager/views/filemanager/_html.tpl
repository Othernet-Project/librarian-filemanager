% if 'html' not in facet_types:
    <span class="note">${_('No documents to be shown.')}</span>
% else:
<%
full_path = th.join(path, index_file)
%>

<div class="views-reader">
    <iframe class="views-reader-frame" src="${url('files:direct', path=full_path)}"></iframe>
</div>
% endif
