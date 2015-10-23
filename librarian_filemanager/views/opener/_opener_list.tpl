<ul class="openers">
    <%
        list_url = i18n_url('files:path', path=path)
        download_url = url('files:direct', path=path) + h.set_qparam(filename=name).to_qs()
    %>
    <li>
    <a class="generic" href="${list_url if is_folder else download_url}">
        <span class="icon icon-generic"></span>
        <span class="name">${_("Explore") if is_folder else _("Download")}</span>
    </a>
    </li>
    % for oid in opener_ids:
    <li>
    <a class="opener-link opener-${oid}" href="${i18n_url('files:path', path=path) + h.set_qparam(action='open', opener_id=oid).to_qs()}">
        <span class="icon icon-${oid}"></span>
        <span class="name">${openers.label(oid)}</span>
    </a>
    </li>
    % endfor
</ul>
