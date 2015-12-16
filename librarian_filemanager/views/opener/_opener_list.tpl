<ul class="openers">
    <%
        list_url = i18n_url('files:path', path=path)
        download_url = h.quoted_url('files:direct', path=path) + h.set_qparam(filename=name).to_qs()
    %>
    % for oid in opener_ids:
    <li class="opener">
    <a class="opener-link opener-${oid}" href="${i18n_url('files:path', path=path) + h.set_qparam(action='open', opener_id=oid).to_qs()}" data-path="${path}" data-type="${oid}">
        <span class="icon icon-${oid}"></span>
        <span class="name">${openers.label(oid)}</span>
    </a>
    </li>
    % endfor
    <li class="opener">
    <a class="opener-generic" href="${list_url if is_folder else download_url}" data-path="${path}" data-type="${'list' if is_folder else 'download'}">
            % if is_folder:
                <span class="icon icon-folder"></span>
                ## Translators, label for an icon view folder contents
                <span class="name">${_("List files")}</span>
            % else:
                <span class="icon icon-download"></span>
                ## Translators, label for an icon to download content
                <span class="name">${_("Download")}</span>
            % endif
        </a>
    </li>
</ul>
<script type="text/javascript" src="${assets['js/openers']}"></script>
