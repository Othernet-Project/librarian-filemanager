"""
files.py: routes related to files section

Copyright 2014-2015, Outernet Inc.
Some rights reserved.

This software is free software licensed under the terms of GPLv3. See COPYING
file that comes with the source code, or http://www.gnu.org/licenses/gpl.txt.
"""

import os
import logging
import functools
import subprocess

from itertools import izip_longest, imap

from bottle import request, abort, static_file, redirect
from bottle_utils.ajax import roca_view
from bottle_utils.csrf import csrf_protect, csrf_token
from bottle_utils.html import urlunquote, quoted_url
from bottle_utils.i18n import lazy_gettext as _, i18n_url

from librarian_core.contrib.templates.decorators import template_helper
from librarian_core.contrib.templates.renderer import template, view
from librarian_content.facets.utils import (get_archive,
                                            get_facets,
                                            get_facet_types,
                                            is_facet_valid,
                                            find_html_index)

from .dirinfo import DirInfo
from .manager import Manager
from .helpers import (title_name,
                      durify,
                      get_selected,
                      get_adjacent,
                      get_thumb_path,
                      find_root,
                      aspectify)


FACET_MAPPING = {
    'video': 'clips',
    'image': 'gallery',
    'audio': 'playlist',
}
EXPORTS = {
    'routes': {'required_by': ['librarian_core.contrib.system.routes.routes']}
}
SHELL = '/bin/sh'


def get_parent_path(path):
    return os.path.normpath(os.path.join(path, '..'))


@template_helper
def get_parent_url(path):
    parent_path = get_parent_path(path)
    return i18n_url('files:path', path=parent_path)


def go_to_parent(path):
    redirect(get_parent_url(path))


@roca_view('filemanager/main', 'filemanager/_main', template_func=template)
def show_file_list(path=None, defaults=None):
    return get_file_list(path, defaults)


def get_file_list(path=None, defaults=None):
    defaults = defaults or {}
    try:
        query = urlunquote(request.params['p']).strip()
    except KeyError:
        query = path or '.'
        is_search = False
    else:
        is_search = True

    manager = Manager(request.app.supervisor)
    if is_search:
        (dirs, files, meta, is_match) = manager.search(query)
        relpath = '.' if not is_match else query
        is_search = not is_match
        is_successful = True  # search is always successful
    else:
        (is_successful, dirs, files, meta) = manager.list(query)
        relpath = '.' if not is_successful else query
    current = manager.get(path)
    up = get_parent_path(query)
    data = defaults.copy()
    data.update(dict(path=relpath,
                     current=current,
                     dirs=dirs,
                     files=files,
                     up=up,
                     is_search=is_search,
                     is_successful=is_successful))
    return data


@roca_view('filemanager/main', 'filemanager/_main', template_func=template)
def show_list_view(path, view, defaults):
    selected = request.query.get('selected', None)
    if selected:
        selected = urlunquote(selected)
    data = defaults.copy()
    paths = [f.rel_path for f in data['files']]
    data['facet_types'] = get_facet_types(paths)
    is_search = data.get('is_search', False)
    is_successful = data.get('is_successful', True)
    if not is_search and is_successful:
        if view == 'html':
            data['index_file'] = find_html_index(paths)
        elif view == 'updates':
            manager = Manager(request.app.supervisor)
            span = request.app.config['changelog.span']
            (_, _, files, _) = manager.list_descendants(path, span)
            data['files'] = sorted(files,
                                   key=lambda x: x.create_date, reverse=True)
        elif view != 'generic':
            data['files'] = filter(
                lambda f: is_facet_valid(f.rel_path, view), data['files'])
    data['selected'] = selected
    return data


@roca_view('filemanager/info', 'filemanager/_info', template_func=template)
def show_info_view(path, view, meta, defaults):
    file_path = os.path.join(path, meta)
    success, fso = request.app.supervisor.exts.fsal.get_fso(file_path)
    if not success:
        # There is no such file
        abort(404)
    try:
        facets = list(get_facets((file_path,), facet_type=view))[0]
    except IndexError:
        abort(404)
    fso.facets = facets
    defaults['entry'] = fso
    return defaults


def show_view(path, view, defaults):
    # Add all helpers
    defaults.update(dict(titlify=title_name, durify=durify,
                         get_selected=get_selected, get_adjacent=get_adjacent,
                         aspectify=aspectify))

    defaults.update(get_file_list(path))
    meta = request.query.get('info')
    if meta:
        meta = urlunquote(meta)
        return show_info_view(path, view, meta, defaults)
    else:
        return show_list_view(path, view, defaults)


def search_content(query, lang=None):
    supervisor = request.app.supervisor
    if not lang:
        default_lang = request.user.options.get('content_language', None)
        lang = request.params.get('language', default_lang)
    content_type = request.params.get('content_type', None)
    dirinfos = DirInfo.search(supervisor, terms=query, language=lang)
    facets = search_facets(terms=query, facet_type=content_type)
    return dirinfos, facets


def search_facets(terms, facet_type=None):
    return get_archive().search(terms, facet_type=facet_type)


def direct_file(path):
    path = urlunquote(path)
    try:
        root = find_root(path)
    except RuntimeError:
        abort(404, _("File not found."))

    download = request.params.get('filename', False)
    return static_file(path, root=root, download=download)


def guard_already_removed(func):
    @functools.wraps(func)
    def wrapper(path, **kwargs):
        manager = Manager(request.app.supervisor)
        if not manager.exists(path):
            # Translators, used as page title when a file's removal is
            # retried, but it was already deleted before
            title = _("File already removed")
            # Translators, used as message when a file's removal is
            # retried, but it was already deleted before
            message = _("The specified file has already been removed.")
            return template('feedback',
                            status='success',
                            page_title=title,
                            message=message,
                            redirect_url=get_parent_url(path),
                            redirect_target=_("Files"))
        return func(path=path, **kwargs)
    return wrapper


@csrf_token
@guard_already_removed
@view('filemanager/remove_confirm')
def delete_path_confirm(path):
    cancel_url = request.headers.get('Referer', get_parent_url(path))
    return dict(item_name=os.path.basename(path), cancel_url=cancel_url)


@csrf_protect
@guard_already_removed
@view('ui/feedback')
def delete_path(path):
    manager = Manager(request.app.supervisor)
    (success, error) = manager.remove(path)
    if success:
        # Translators, used as page title of successful file removal feedback
        page_title = _("File removed")
        # Translators, used as message of successful file removal feedback
        message = _("File successfully removed.")
        return dict(status='success',
                    page_title=page_title,
                    message=message,
                    redirect_url=get_parent_url(path),
                    redirect_target=_("file list"))

    # Translators, used as page title of unsuccessful file removal feedback
    page_title = _("File not removed")
    # Translators, used as message of unsuccessful file removal feedback
    message = _("File could not be removed.")
    return dict(status='error',
                page_title=page_title,
                message=message,
                redirect_url=get_parent_url(path),
                redirect_target=_("file list"))


def rename_path(path):
    new_name = request.forms.get('name')
    if not new_name:
        go_to_parent(path)

    manager = Manager(request.app.supervisor)
    new_name = os.path.normpath(new_name)
    new_path = os.path.join(os.path.dirname(path), new_name)
    manager.move(path, new_path)
    go_to_parent(path)


def run_path(path):
    path = os.path.join(request.app.config['library.contentdir'], path)
    callargs = [SHELL, path]
    proc = subprocess.Popen(callargs,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    out, err = proc.communicate()
    ret = proc.returncode
    return ret, out, err


def init_file_action(path=None):
    if path:
        path = urlunquote(path)
    else:
        path = '.'
    # Use 'generic' as default view
    view = request.query.get('view', 'generic')
    defaults = dict(path=path,
                    view=view)
    action = request.query.get('action')
    if action:
        return show_files_view(path, action, defaults)
    return show_view(path, view, defaults)


def show_files_view(path, action, defaults):
    if action == 'delete':
        return delete_path_confirm(path)
    elif action == 'thumb':
        return retrieve_thumb_url(path, defaults)

    return show_file_list(path, defaults=defaults)


def handle_file_action(path):
    path = urlunquote(path)
    action = request.forms.get('action')
    if action == 'rename':
        return rename_path(path)
    elif action == 'delete':
        return delete_path(path)
    elif action == 'exec':
        if os.path.splitext(path)[1] != '.sh':
            # For now we only support running BASH scripts
            abort(400)
        logging.info("Running script '%s'", path)
        ret, out, err = run_path(path)
        logging.debug("Script '%s' finished with return code %s", path, ret)
        return template('exec_result', ret=ret, out=out, err=err)
    else:
        abort(400)


def retrieve_thumb_url(path, defaults):
    thumb_url = None
    thumb_path = get_thumb_path(urlunquote(request.query.get('target')))
    if thumb_path:
        thumb_url = quoted_url('files:direct', path=thumb_path)
    else:
        facet_type = request.query.get('facet', 'generic')
        try:
            facet = defaults['facets'][facet_type]
        except KeyError:
            pass
        else:
            cover = facet.get('cover')
            if cover:
                cover_path = os.path.join(facet['path'], cover)
                thumb_url = quoted_url('files:direct',
                                       path=cover_path)

    return dict(url=thumb_url)


def routes(config):
    return (
        ('files:list', init_file_action,
         'GET', '/files/', dict(unlocked=True)),
        ('files:path', init_file_action,
         'GET', '/files/<path:path>', dict(unlocked=True)),
        ('files:action', handle_file_action,
         'POST', '/files/<path:path>', dict(unlocked=True)),
        ('files:direct', direct_file,
         'GET', '/direct/<path:path>', dict(unlocked=True)),
    )
