<%inherit file="/narrow_base.tpl"/>
<%namespace name="info" file="_info.tpl"/>

<%block name="title">
    ## Translators, used as page title on a page that shows file details
    ${_('{title} details').format(title=entry['title'] or titlify(entry['file']))}
</%block>

${info.body()}
