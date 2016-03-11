"""
files.py: routes related to files section

Copyright 2014-2015, Outernet Inc.
Some rights reserved.

This software is free software licensed under the terms of GPLv3. See COPYING
file that comes with the source code, or http://www.gnu.org/licenses/gpl.txt.
"""

import functools
import logging
import os
import subprocess

from bottle import request, abort, static_file, redirect
from bottle_utils.ajax import roca_view
from bottle_utils.csrf import csrf_protect, csrf_token
from bottle_utils.html import urlunquote
from bottle_utils.i18n import lazy_gettext as _, i18n_url

from librarian_content.library import metadata
from librarian_content.library.archive import Archive
from librarian_content.library.facets.utils import get_facets
from librarian_core.contrib.templates.decorators import template_helper
from librarian_core.contrib.templates.renderer import template, view

from .manager import Manager
from .helpers import (enrich_facets,
                      title_name,
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
def show_file_list(path=None, defaults=dict()):
    try:
        query = urlunquote(request.params['p'])
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

    up = get_parent_path(query)
    data = defaults.copy()
    data.update(dict(path=relpath,
                     dirs=dirs,
                     files=files,
                     up=up,
                     is_search=is_search,
                     is_successful=is_successful,
                     openers=request.app.supervisor.exts.openers))
    return data


@roca_view('filemanager/main', 'filemanager/_main', template_func=template)
def show_list_view(path, view, defaults):
    selected = request.query.get('selected', None)
    if selected:
        selected = urlunquote(selected)
    data = defaults.copy()
    data.update(dict(selected=selected))
    return data


@roca_view('filemanager/info', 'filemanager/_info', template_func=template)
def show_info_view(path, view, defaults):
    return defaults


def filter_facet_item(facets, view, item_path):
    facet = facets[view][FACET_MAPPING[view]]
    return filter(lambda x: x['file'] == item_path, facet)[0]


def show_view(path, view, defaults):
    meta = request.query.get('info')
    # Add all helpers
    defaults.update(dict(titlify=title_name, durify=durify,
                         get_selected=get_selected, get_adjacent=get_adjacent,
                         aspectify=aspectify))
    if meta:
        meta = urlunquote(meta)
        try:
            entry = filter_facet_item(defaults['facets'], view, meta)
        except (KeyError, IndexError):
            # There is no such facet or no such item in the facet
            abort(404)
        defaults.update(dict(entry=entry))
        return show_info_view(path, view, defaults)
    return show_list_view(path, view, defaults)


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
    facets = get_facets(path)
    defaults = dict(path=path,
                    view=view,
                    facets=facets)
    if view == 'generic':
        return show_files_view(path, defaults)
    else:
        fsal = request.app.supervisor.exts.fsal
        success, ignored, files = fsal.list_dir(path)
        files = files if success else []
        enrich_facets(facets, files=files)
        is_successful = facets is not None
        up = get_parent_path(path)
        defaults.update(up=up, is_successful=is_successful)
        return show_view(path, view, defaults)


def show_files_view(path, defaults):
    action = request.query.get('action')
    if action == 'delete':
        return delete_path_confirm(path)
    elif action == 'open':
        return opener_detail(request.query.get('opener_id'), path=path)
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


def opener_list():
    openers = request.app.supervisor.exts.openers
    manager = Manager(request.app.supervisor)
    path = urlunquote(request.query.get('path', ''))
    name = os.path.basename(path)
    is_folder = manager.isdir(path)
    content_types = request.query.getall('content_type')
    if content_types:
        opener_ids = []
        for ct in content_types:
            opener_ids.extend(openers.filter_by(content_type=ct))
    else:
        (_, ext) = os.path.splitext(name)
        opener_ids = openers.filter_by(extension=ext.strip('.'))

    context = dict(opener_ids=opener_ids,
                   openers=request.app.supervisor.exts.openers,
                   path=path,
                   name=name,
                   is_folder=is_folder)

    if request.is_xhr:
        return template('opener/_opener_list', **context)

    # for non-ajax requests, if there are no openers available, use the generic
    # opener automatically
    if not opener_ids:
        if not is_folder:
            # the selected path is a file, just trigger the download
            return direct_file(path)
        # redirect to show the contents of the folder
        redirect(i18n_url('files:path', path=path))
    # show list of openers
    return template('opener/opener_list', **context)


def opener_detail(opener_id, path=None):
    path = path or urlunquote(request.query.get('path', ''))
    opener = request.app.supervisor.exts.openers.get(opener_id)
    conf = request.app.config
    archive = Archive.setup(conf['library.backend'],
                            request.app.supervisor.exts.fsal,
                            request.db.content,
                            contentdir=conf['library.contentdir'],
                            meta_filenames=conf['library.metadata'])
    content = archive.get_single(path)
    meta = metadata.Meta(request.app.supervisor,
                         path,
                         data=content) if content else None
    opener_html = opener(path)
    if request.is_xhr:
        return opener_html

    return template('opener/opener_detail',
                    opener_id=opener_id,
                    openers=request.app.supervisor.exts.openers,
                    opener_html=opener_html,
                    path=path,
                    filename=os.path.basename(path),
                    meta=meta)


def retrieve_thumb_url(path, defaults):
    thumb_url = None
    thumb_path = get_thumb_path(urlunquote(request.query.get('target')))
    if thumb_path:
        thumb_url = request.app.get_url('files:direct', path=thumb_path)
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
                thumb_url = request.app.get_url('files:direct',
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
        ('opener:list', opener_list,
         'GET', '/openers/', dict(unlocked=True)),
        ('opener:detail', opener_detail,
         'GET', '/openers/<opener_id>/', dict(unlocked=True)),
    )
