<div class="openers">
% for oid in opener_ids:
    <a class="${oid}" href="${i18n_url('opener:detail', opener_id=oid) + h.set_qparam(path=path).to_qs()}">
        <span class="icon"></span>
        <span class="name">${oid}</span>
    </a>
% endfor
</div>
