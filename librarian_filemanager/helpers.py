import os
import functools
import fractions
from itertools import ifilter

from bottle import request
from bottle_utils.i18n import i18n_url

from librarian_core.contrib.templates.decorators import template_helper
from librarian_content.library.facets.processors import FacetProcessorBase

ICON_MAPPINGS = {
    'text/x-python': 'file-xml',
    'text/html': 'file-text-image',
    'text/plain': 'file-text',
    'image/png': 'file-image',
    'image/jpeg': 'file-image',
    'audio/mpeg': 'file-audio',
    'video/mp4': 'file-video',
}

EXTENSION_VIEW_MAPPING = {
    'jpg': 'image',
    'jpeg': 'image',
    'jpe': 'image',
    'png': 'image',
    'gif': 'image',
    'html': 'html',
    'htm': 'html',
    'xhtml': 'html',
    'mp3': 'audio',
    'wav': 'audio',
    'ogg': 'audio',
    'mp4': 'video',
    'wmv': 'video',
    'webm': 'video',
    'flv': 'video',
    'ogv': 'video',
}


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
def get_folder_cover(fsobj):
    cover = fsobj.dirinfo.get(request.locale, 'cover', None)
    if cover:
        # There is a cover image
        cover_path = fsobj.other_path(cover)
        return i18n_url('files:direct', path=cover_path)
    # Look for default cover
    default_cover = fsobj.other_path('cover.jpg')
    if not request.app.supervisor.exts.fsal.exists(default_cover):
        return
    fsobj.dirinfo.set('cover', 'cover.jpg')
    fsobj.dirinfo.store()
    return i18n_url('files:direct', path=default_cover)


@template_helper
def get_folder_icon(fsobj):
    """
    Return folder icon or icon URL and a flag that tells us whether icon is a
    URL or not
    """
    icon = fsobj.dirinfo.get(request.locale, 'icon', None)
    if icon:
        # Dirinfo has an icon, so let's use that
        return i18n_url('files:direct', path=fsobj.other_path(icon)), True
    # Since dirinfo does not have an icon for us, we'll see if there's an icon
    # for a view
    view = fsobj.dirinfo.get(request.locale, 'view', 'generic')
    return 'folder' if view == 'generic' else view, False


@template_helper
def get_folder_view_url(fsobj):
    """
    Returns the url of the default view for specified folder.
    """
    default_view = fsobj.dirinfo.get(request.locale, 'view', None)
    varg = {'view': default_view} if default_view else {}
    return i18n_url('files:path', path=fsobj.rel_path, **varg)


@template_helper
def get_folder_name(fsobj):
    """
    Return folder title, name, or filesystem name, whichever is present in the
    dirinfo.
    """
    title = fsobj.dirinfo.get(request.locale, 'title', None)
    name = fsobj.dirinfo.get(request.locale, 'name', None)
    return title or name or fsobj.name


@template_helper
def get_file_icon(fsobj):
    return ICON_MAPPINGS.get(fsobj.mimetype, 'file')


@template_helper
def get_view_path(fsobj):
    """
    Return a view URL with specified file preselected.
    """
    ext = fsobj.rel_path.rsplit('.', 1)[-1]
    view = EXTENSION_VIEW_MAPPING.get(ext)
    if not view:
        return i18n_url('files:direct', path=fsobj.rel_path)
    parent = fsobj.rel_path.rsplit('/', 1)[0]
    return i18n_url('files:path', path=parent, view=view, selected=fsobj.name)


@template_helper
def get_file_thumb(fsobj):
    """
    Return icon name or thumbnail URL and flag that tells us if returned value
    is an URL.
    """
    ext = fsobj.rel_path.rsplit('.', 1)[-1]
    thumb = None
    if EXTENSION_VIEW_MAPPING.get(ext) == 'image':
        try:
            thumb = get_thumb_path(fsobj.rel_path)
        except Exception:
            pass
    else:
        thumb = None
    if not thumb:
        # No thumb for this file, so let's try an icon
        return get_file_icon(fsobj), False
    else:
        return i18n_url('files:direct', path=thumb), True


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
