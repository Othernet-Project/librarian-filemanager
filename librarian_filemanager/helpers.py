import os

from bottle import request

from librarian_content.library.facets.archive import FacetsArchive


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
    minutes, seconds = divmod(seconds, 60.0)
    return '{}:{:02d}:{:02d}'.format(int(hours), int(minutes), int(seconds))


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
