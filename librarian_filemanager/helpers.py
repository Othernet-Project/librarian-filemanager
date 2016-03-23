import os
import functools
import fractions
from itertools import ifilter

from bottle import request
from bottle_utils.i18n import i18n_url

from librarian_core.contrib.templates.decorators import template_helper
from librarian_content.library.facets.processors import FacetProcessorBase


def get_file(files, path):
    return next(ifilter(lambda f: f.rel_path == path, files), None)


def title_name(path):
    """ Return best-effort-titlified file path """
    name, _ = os.path.splitext(path)
    return name.replace('_', ' ').replace('-', ' ')


def durify(seconds):
    hours, seconds = divmod(seconds, 3600.0)
    if hours:
        whole_mins = round(seconds / 60.0)
        return '{}h{:02d}'.format(int(hours), int(whole_mins))
    minutes, seconds = divmod(seconds, 60.0)
    return '{}:{:02d}'.format(int(minutes), int(seconds))


def aspectify(w, h):
    if min(w, h) == 0:
        return '0'
    aspect = fractions.Fraction(w, h).limit_denominator(10)
    return '{}:{}'.format(aspect.numerator, aspect.denominator)


def get_selected(collection, selected=None):
    selected_entries = list(filter(lambda f: f.name == selected,
                                   collection))
    return selected_entries[0] if selected_entries else collection[0]


def get_adjacent(collection, current, loop=True):
    current_idx = collection.index(current)
    if loop:
        previous_idx = current_idx - 1
        next_idx = (current_idx + 1) % len(collection)
    else:
        previous_idx = max(current_idx - 1, 0)
        next_idx = min(current_idx + 1, len(collection) - 1)
    return collection[previous_idx], collection[next_idx]


def find_root(path):
    (_, base_paths) = request.app.supervisor.exts.fsal.list_base_paths()
    for root in base_paths:
        if os.path.exists(os.path.join(root, path)):
            return root
    raise RuntimeError("Root path cannot be determined")


def thumb_exists(root, thumbpath):
    cache = request.app.supervisor.exts(onfail=None).cache
    if cache.get(thumbpath):
        return True

    exists = os.path.exists(os.path.join(root, thumbpath))
    if exists:  # just so we save cache storage
        cache.set(thumbpath, True)
    return exists


def thumb_created(cache, srcpath, thumbpath):
    if thumbpath:
        cache.set(thumbpath, True)


@template_helper
def pjoin(*args):
    return '/'.join(args)


@template_helper
def get_folder_cover(fsobj):
    cover = fsobj.dirinfo.get(request.locale, 'cover', None)
    if cover:
        # There is a cover image
        cover_path = pjoin(fsobj.rel_path, cover)
        return i18n_url('files:direct', path=cover_path)
    # Look for default cover
    default_cover = pjoin(fsobj.rel_path, 'cover.jpg')
    if not request.app.supervisor.exts.fsal.exists(default_cover):
        return
    fsobj.dirinfo.set('cover', 'cover.jpg')
    fsobj.dirinfo.store()
    return i18n_url('files:direct', path=default_cover)


@template_helper
def get_thumb_path(srcpath, default=None):
    try:
        root = find_root(srcpath)
    except RuntimeError:
        return srcpath
    else:
        config = request.app.config
        proc_cls = FacetProcessorBase.get_processor(srcpath)
        thumbpath = proc_cls.determine_thumb_path(srcpath,
                                                  config['thumbs.dirname'],
                                                  config['thumbs.extension'])
        if thumb_exists(root, thumbpath):
            return thumbpath

        cache = request.app.supervisor.exts(onfail=None).cache
        callback = functools.partial(thumb_created, cache)
        kwargs = dict(srcpath=os.path.join(root, srcpath),
                      thumbpath=os.path.join(root, thumbpath),
                      root=root,
                      size=config['thumbs.size'],
                      quality=config['thumbs.quality'],
                      callback=callback,
                      default=default)
        if config['thumbs.async']:
            tasks = request.app.supervisor.exts.tasks
            tasks.schedule(proc_cls.create_thumb, kwargs=kwargs)
            return srcpath

        return proc_cls.create_thumb(**kwargs)
