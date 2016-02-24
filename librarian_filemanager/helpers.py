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
