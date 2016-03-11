import os
import functools
import fractions

from bottle import request

from librarian_content.library.facets.archive import FacetsArchive
from librarian_content.library.facets.metadata import run_command
from librarian_core.contrib.templates.decorators import template_helper


def get_facets(path):
    supervisor = request.app.supervisor
    archive = FacetsArchive(supervisor.exts.fsal,
                            supervisor.exts.databases.facets,
                            config=supervisor.config)
    facets = archive.get_facets(path)
    process_facets(facets)
    return facets


def process_facets(facets):
    pathify(facets)


def pathify(data):
    if hasattr(data, 'items'):
        if 'path' in data and 'file' in data:
            data['file_path'] = os.path.join(data['path'], data['file'])
        else:
            for _, value in data.items():
                pathify(value)
    elif isinstance(data, list):
        for item in data:
            pathify(item)


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
    aspect = fractions.Fraction(w, h)
    return '{}:{}'.format(aspect.numerator, aspect.denominator)


def get_selected(collection, selected=None):
    selected_entries = list(filter(lambda e: e['file'] == selected,
                                   collection))
    return selected_entries[0] if selected_entries else collection[0]


def get_adjacent(collection, current, loop=True):
    collection = list(collection)
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


def determine_thumb_path(imgpath, thumbdir, extension):
    imgdir = os.path.dirname(imgpath)
    filename = os.path.basename(imgpath)
    (name, _) = os.path.splitext(filename)
    newname = '.'.join([name, extension])
    return os.path.join(imgdir, thumbdir, newname)


def ffmpeg_cmd(src, dest, width, height, quality):
    cmd = ["ffmpeg",
           "-i",
           src,
           "-q:v",
           str(quality),
           "-vf",
           "scale='if(gt(in_w,in_h),-1,{height})':'if(gt(in_w,in_h),{width},-1)',crop={width}:{height}".format(width=width, height=height),  # NOQA
           dest]
    return run_command(cmd, timeout=5, debug=True)


def create_thumb(imgpath, thumbpath, size, quality, callback=None):
    if os.path.exists(thumbpath):
        return

    thumbdir = os.path.dirname(thumbpath)
    if not os.path.exists(thumbdir):
        os.makedirs(thumbdir)

    (width, height) = map(int, size.split('x'))
    ffmpeg_cmd(imgpath, thumbpath, width, height, quality)
    if callback:
        callback(imgpath, thumbpath)


def thumb_exists(root, thumbpath):
    cache = request.app.supervisor.exts(onfail=None).cache
    if cache.get(thumbpath):
        return True

    exists = os.path.exists(os.path.join(root, thumbpath))
    if exists:  # just so we save cache storage
        cache.set(thumbpath, True)
    return exists


def thumb_created(cache, imgpath, thumbpath):
    cache.set(thumbpath, True)


@template_helper
def get_thumb_path(imgpath):
    try:
        root = find_root(imgpath)
    except RuntimeError:
        return imgpath
    else:
        config = request.app.config
        thumbpath = determine_thumb_path(imgpath,
                                         config['thumbs.dirname'],
                                         config['thumbs.extension'])
        if thumb_exists(root, thumbpath):
            return thumbpath

        cache = request.app.supervisor.exts(onfail=None).cache
        callback = functools.partial(thumb_created, cache)
        kwargs = dict(imgpath=os.path.join(root, imgpath),
                      thumbpath=os.path.join(root, thumbpath),
                      size=config['thumbs.size'],
                      quality=config['thumbs.quality'],
                      callback=callback)
        if config['thumbs.async']:
            tasks = request.app.supervisor.exts.tasks
            tasks.schedule(create_thumb, kwargs=kwargs)
            return imgpath

        create_thumb(**kwargs)
        return thumbpath

