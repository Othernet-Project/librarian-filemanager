<%namespace name="current_view" file="_${context['view']}.tpl"/>

<%!
# Mappings between facets and view urls
_ = lambda x: x
FACET_VIEW_MAPPINGS = (
    ('generic', 'files', _('Browse')),
    ('image', 'gallery', _('Gallery')),
    ('audio', 'playlist', _('Listen')),
    ('video', 'clips', _('Watch')),
    ('html', 'read', _('Read'))
)


def get_views(facets):
    result = list()
    if not facets:
        default = FACET_VIEW_MAPPINGS[0]
        result.append((default[1], default[2]))
        return result
    for facet_type, name, label in FACET_VIEW_MAPPINGS:
        if facets.has_type(facet_type):
            result.append((name, label))
    return result
%>

<div id="views-tabs-container">
    <nav id="views-tabs-strip" class="views-tabs-strip" role="tablist">
    % for name, label in get_views(facets):
        <%
        view_url = i18n_url('files:path', path=path, view=name)
        current = name == view
        %>
        <a class="views-tabs-strip-tab views-tab-tab-link ${'view-tabs-tab-current' if current else ''}" href="${view_url}" role="tab">
            <span class="icon view-icon-${name}"></span>
            <span class="views-tabs-tab-label">${_(label)}</span>
        </a>
    % endfor
    </nav>
</div>
<div class="views-container" id="views-container">
    ${current_view.body()}
</div>

