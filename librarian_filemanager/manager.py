import os

import scandir

from .dirinfo import DirInfo


META_FILES = (DirInfo.FILENAME, '.contentinfo')


class FSObject(object):

    def __init__(self, path, size=None, date_created=None, date_modified=None):
        self.path = path
        self.size = size
        self.date_created = date_created
        self.date_modified = date_modified


def listdir(path):
    dirs = []
    files = []
    for entry in scandir.scandir(path):
        if entry.is_dir():
            fso = FSObject(path=entry.path,
                           size=None,
                           date_created=None,
                           date_modified=None)
            dirs.append(fso)
        else:
            fso = FSObject(path=entry.path,
                           size=entry.stat().st_size,
                           date_created=None,
                           date_modified=None)
            files.append(fso)

    return (dirs, files)


class Manager(object):

    def __init__(self, supervisor):
        self.supervisor = supervisor

    def get_dirinfo(self, path):
        return DirInfo.from_db(self.supervisor, path)

    def list(self, path, relative_to):
        meta = {}
        files = []
        dirs = []
        (dirs, unfiltered_files) = listdir(path)
        for fs_obj in dirs:
            fs_obj.name = os.path.basename(fs_obj.path)
            fs_obj.relpath = os.path.relpath(fs_obj.path, relative_to)
            fs_obj.dirinfo = self.get_dirinfo(fs_obj.path)

        for fs_obj in unfiltered_files:
            fs_obj.name = os.path.basename(fs_obj.path)
            fs_obj.relpath = os.path.relpath(fs_obj.path, relative_to)
            if fs_obj.name in META_FILES:
                meta[fs_obj.name] = fs_obj
            else:
                files.append(fs_obj)

        return (dirs, files, meta)

    def find(self, query):
        dirs = []
        files = []
        return (dirs, files, {})
