<% 
full_path = '/'.join([facets['html']['path'], facets['html']['index']])
%>

<div class="views-reader">
    <iframe class="views-reader-frame" src="${url('files:direct', path=full_path)}"></iframe>
</div>
