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
import shutil
import subprocess

from bottle import request, abort, static_file, redirect
from bottle_utils.ajax import roca_view
from bottle_utils.csrf import csrf_protect, csrf_token
from bottle_utils.i18n import lazy_gettext as _, i18n_url

from librarian_content.library import metadata
from librarian_content.library.archive import Archive
from librarian_core.contrib.templates.renderer import template, view

from .manager import Manager


EXPORTS = {
    'routes': {'required_by': ['librarian_system.routes.routes']}
}
SHELL = '/bin/sh'


def get_full_path(path):
    filedir = os.path.normpath(request.app.config['files.rootdir'])
    path = os.path.normpath(path.replace('..', '.'))
    full = os.path.normpath(os.path.join(filedir, path))
    if full.startswith(filedir):
        return full
    return filedir


@view('file_list')
def show_file_list(path=None):
    search = request.params.get('p')
    rootdir = request.app.config['files.rootdir']
    query = get_full_path(search or path or '.')
    manager = Manager(request.app.supervisor)
    try:
        (dirs, files, meta) = manager.list(query, relative_to=rootdir)
    except OSError:
        relpath = '.'
        if search:
            (dirs, files, meta) = manager.find(search)
        else:
            dirs = files = []
    else:
        relpath = os.path.relpath(query, rootdir)

    up = os.path.relpath(os.path.normpath(os.path.join(query, '..')), rootdir)
    return dict(path=relpath,
                dirs=dirs,
                files=files,
                up=up,
                openers=request.app.supervisor.exts.openers)


def direct_file(path):
    return static_file(path, root=request.app.config['files.rootdir'])


def get_parent_url(path):
    parent_dir = os.path.dirname(path)
    filedir = request.app.config['files.rootdir']
    parent_path = os.path.relpath(parent_dir, filedir) if parent_dir else ''
    return i18n_url('files:path', path=parent_path)


def go_to_parent(path):
    redirect(get_parent_url(path))


def guard_already_removed(func):
    @functools.wraps(func)
    def wrapper(path, **kwargs):
        path = get_full_path(path)
        if not os.path.exists(path):
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
    if not os.path.exists(path):
        abort(404)
    if os.path.isdir(path):
        if path == request.app.config['files.filedir']:
            # FIXME: handle this case
            abort(400)
        shutil.rmtree(path)
    else:
        os.unlink(path)

    # Translators, used as page title of successful file removal feedback
    page_title = _("File removed")
    # Translators, used as message of successful file removal feedback
    message = _("File successfully removed.")
    return dict(status='success',
                page_title=page_title,
                message=message,
                redirect_url=get_parent_url(path),
                redirect_target=_("Files"))


def rename_path(path):
    new_name = request.forms.get('name')
    if not new_name:
        go_to_parent(path)
    new_name = os.path.normpath(new_name)
    new_path = os.path.join(os.path.dirname(path), new_name)
    shutil.move(path, new_path)
    go_to_parent(path)


def run_path(path):
    callargs = [SHELL, path]
    proc = subprocess.Popen(callargs,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    out, err = proc.communicate()
    ret = proc.returncode
    return ret, out, err


def init_file_action(path):
    action = request.query.get('action')
    if action == 'delete':
        return delete_path_confirm(path)
    elif action == 'open':
        return opener_detail(path, request.query.get('opener_id'))

    return show_file_list(path)


def handle_file_action(path):
    action = request.forms.get('action')
    path = get_full_path(path)
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


@roca_view('opener_list', '_opener_list', template_func=template)
def opener_list():
    path = request.query.get('path', '')
    filename = os.path.basename(path)
    (_, ext) = os.path.splitext(filename)
    opener_ids = request.app.supervisor.exts.openers.filter_for(ext.strip('.'))
    return dict(opener_ids=opener_ids, path=path)


@view('opener_detail')
def opener_detail(path, opener_id):
    conf = request.app.config
    archive = Archive.setup(conf['library.backend'],
                            request.db.content,
                            contentdir=conf['library.contentdir'],
                            meta_filename=conf['library.metadata'])
    content = archive.get_single(path)
    if content:
        content_path = os.path.join(archive.config['contentdir'], path)
        meta = metadata.Meta(content, content_path)
    else:
        meta = None

    return dict(opener_id=opener_id,
                path=path,
                filename=os.path.basename(path),
                meta=meta)


def opener_dispatch(opener_id):
    path = request.query.get('path', '')
    opener = request.app.supervisor.exts.openers.get(opener_id)
    return opener(path)


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
        ('opener:dispatch', opener_dispatch,
         'GET', '/openers/<opener_id>/', dict(unlocked=True)),
    )
