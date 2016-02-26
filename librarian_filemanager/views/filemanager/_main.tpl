<%namespace name="current_view" file="_${context['view']}.tpl"/>

<%!
# Mappings between facets and view urls
FACET_VIEW_MAPPINGS = (
    ('generic', 'files', 'Browse'),
    ('image', 'gallery', 'Gallery'),
    ('audio', 'playlist', 'Audio'),
    ('video', 'clips', 'Watch'),
    ('html', 'read', 'Read')
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
    <ul id="views-tabs-strip" class="views-tabs-strip" role="tablist">
    % for name, label in get_views(facets):
        <%
        view_url = i18n_url('files:path', path=path, view=name)
        current = name == view
        %>
         <li class="views-tabs-strip-tab ${'view-tabs-tab-current' if current else ''}" role="tab">
             <span class="icon view-icon-${name}"></span>
             <a class="views-tabs-tab-link" href="${view_url}">${_(label)}</a>
         </li>
    % endfor
    </ul>
</div>
<div class="views-container" id="views-container">
    ${current_view.body()}
</div>

