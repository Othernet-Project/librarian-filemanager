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
from librarian_core.contrib.templates.decorators import template_helper
from librarian_core.contrib.templates.renderer import template, view

from .manager import Manager


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


@roca_view('filemanager/list', 'filemanager/_list', template_func=template)
def show_file_list(path=None):
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
        is_successful = True  # search is always successful
    else:
        (is_successful, dirs, files, meta) = manager.list(query)
        relpath = '.' if not is_successful else query

    up = get_parent_path(query)
    return dict(path=relpath,
                dirs=dirs,
                files=files,
                up=up,
                is_search=is_search,
                is_successful=is_successful,
                openers=request.app.supervisor.exts.openers)


def direct_file(path):
    path = urlunquote(path)
    return static_file(path,
                       root=request.app.config['library.contentdir'],
                       download=request.params.get('filename', False))


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
@view('remove_confirm')
def delete_path_confirm(path):
    cancel_url = request.headers.get('Referer', get_parent_url(path))
    return dict(item_name=os.path.basename(path), cancel_url=cancel_url)


@csrf_protect
@guard_already_removed
@view('feedback')
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
                    redirect_target=_("Files"))

    # Translators, used as page title of unsuccessful file removal feedback
    page_title = _("File not removed")
    # Translators, used as message of unsuccessful file removal feedback
    message = _("File could not be removed.")
    return dict(status='error',
                page_title=page_title,
                message=message,
                redirect_url=get_parent_url(path),
                redirect_target=_("Files"))


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


def init_file_action(path):
    path = urlunquote(path)
    action = request.query.get('action')
    if action == 'delete':
        return delete_path_confirm(path)
    elif action == 'open':
        return opener_detail(request.query.get('opener_id'), path=path)

    return show_file_list(path)


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


def routes(config):
    return (
        ('files:list', show_file_list,
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
