<div class="openers">
% for oid in opener_ids:
    <a class="${oid}" href="${i18n_url('files:path', path=path) + h.set_qparam(action='open', opener_id=oid).to_qs()}">
        <span class="icon"></span>
        <span class="name">${oid}</span>
    </a>
% endfor
</div>
