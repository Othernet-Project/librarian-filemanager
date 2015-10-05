<div class="openers">
    <%
        list_url = i18n_url('files:path', path=path)
        download_url = url('files:direct', path=path) + h.set_qparam(filename=name).to_qs()
    %>
    <a class="generic" href="${list_url if is_folder else download_url}">
        <span class="icon"></span>
        <span class="name">${_("Explore") if is_folder else _("Download")}</span>
    </a>
    % for oid in opener_ids:
    <a class="${oid}" href="${i18n_url('files:path', path=path) + h.set_qparam(action='open', opener_id=oid).to_qs()}">
        <span class="icon"></span>
        <span class="name">${oid}</span>
    </a>
    % endfor
</div>
