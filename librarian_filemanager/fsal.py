import os

import scandir


def listdir(path, relative_to):
    dirs = []
    files = []
    for entry in scandir.scandir(path):
        name = os.path.basename(entry.name)
        if entry.is_dir():
            dirs.append({'name': name,
                         'path': os.path.relpath(entry.path, relative_to)})
        else:
            files.append({'name': name,
                          'ext': os.path.splitext(name)[1],
                          'path': os.path.relpath(entry.path, relative_to),
                          'size': entry.stat().st_size})

    return (dirs, files)


def find(query):
    dirs = []
    files = []
    return (dirs, files)
