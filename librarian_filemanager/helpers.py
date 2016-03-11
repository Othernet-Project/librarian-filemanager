import functools
import os

from bottle import request

from librarian_content.library.facets.archive import FacetsArchive
from librarian_content.library.facets.metadata import run_command
from librarian_content.library.facets.processors import FacetProcessorBase
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


def runnable(name, timeout=5, debug=True):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            cmd = func(*args, **kwargs)
            return run_command(cmd, timeout=timeout, debug=debug)
        runnable.registry[name] = wrapper
        return wrapper
    return decorator
runnable.registry = dict()


@runnable('image')
def ffmpeg_thumb(src, dest, width, height, quality, **kwargs):
    return [
        "ffmpeg",
        "-i",
        src,
        "-q:v",
        str(quality),
        "-vf",
        "scale='if(gt(in_w,in_h),-1,{height})':'if(gt(in_w,in_h),{width},-1)',crop={width}:{height}".format(width=width, height=height),  # NOQA
        dest
    ]


@runnable('audio')
def ffmpeg_audio(src, dest, **kwargs):
    return [
        "ffmpeg",
        "-i",
        src,
        "-an",
        "-vcodec",
        "copy",
        dest
    ]


@runnable('video')
def ffmpeg_video(src, dest, skip_secs=3, **kwargs):
    return [
        "ffmpeg",
        "-ss",
        str(skip_secs),
        "-i",
        src,
        "-vf",
        "select=gt(scene\,0.5)",
        "-frames:v",
        "1",
        "-vsync",
        "vfr",
        dest
    ]


def create_thumb(srcpath, thumbpath, size, quality, callback=None,
                 default=None):
    if os.path.exists(thumbpath):
        return

    thumbdir = os.path.dirname(thumbpath)
    if not os.path.exists(thumbdir):
        os.makedirs(thumbdir)

    (width, height) = map(int, size.split('x'))
    srctype = FacetProcessorBase.get_processor(srcpath).name
    cmd_fn = runnable.registry[srctype]
    (ret, _) = cmd_fn(srcpath,
                      thumbpath,
                      width=width,
                      height=height,
                      quality=quality)
    result = thumbpath if ret == 0 else default
    if callback:
        callback(srcpath, result)

    return result


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
def get_thumb_path(srcpath, default=None):
    try:
        root = find_root(srcpath)
    except RuntimeError:
        return srcpath
    else:
        config = request.app.config
        thumbpath = determine_thumb_path(srcpath,
                                         config['thumbs.dirname'],
                                         config['thumbs.extension'])
        if thumb_exists(root, thumbpath):
            return thumbpath

        cache = request.app.supervisor.exts(onfail=None).cache
        callback = functools.partial(thumb_created, cache)
        kwargs = dict(srcpath=os.path.join(root, srcpath),
                      thumbpath=os.path.join(root, thumbpath),
                      size=config['thumbs.size'],
                      quality=config['thumbs.quality'],
                      callback=callback,
                      default=default)
        if config['thumbs.async']:
            tasks = request.app.supervisor.exts.tasks
            tasks.schedule(create_thumb, kwargs=kwargs)
            return srcpath

        return create_thumb(**kwargs)

