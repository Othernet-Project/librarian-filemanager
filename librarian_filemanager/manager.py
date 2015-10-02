import os

import scandir

from bottle_utils import html
from bottle_utils.i18n import i18n_url

from librarian_content.library import metadata
from librarian_content.library.archive import Archive

from .dirinfo import DirInfo


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
        conf = supervisor.config
        self.archive = Archive.setup(conf['library.backend'],
                                     supervisor.exts.databases.content,
                                     contentdir=conf['library.contentdir'],
                                     meta_filename=conf['library.metadata'])
        self.META_FILES = (DirInfo.FILENAME, conf['library.metadata'])

    def get_dirinfo(self, path):
        return DirInfo.from_db(self.supervisor, path)

    def get_contentinfo(self, path):
        key = 'meta_{0}'.format(path)
        content = None
        if self.supervisor.exts.is_installed('cache'):
            content = self.supervisor.exts.cache.get(key)

        if not content:
            content = self.archive.get_single(path)

        if content:
            content_path = os.path.join(self.archive.config['contentdir'],
                                        path)
            return metadata.Meta(content, content_path)

        return None

    def list(self, path, relative_to):
        meta = {}
        files = []
        dirs = []
        (dirs, unfiltered_files) = listdir(path)
        for fs_obj in dirs:
            fs_obj.name = os.path.basename(fs_obj.path)
            fs_obj.relpath = os.path.relpath(fs_obj.path, relative_to)
            fs_obj.dirinfo = self.get_dirinfo(fs_obj.relpath)
            fs_obj.contentinfo = self.get_contentinfo(fs_obj.relpath)
            if fs_obj.contentinfo:
                query = html.QueryDict()
                query.add_qparam(path=fs_obj.relpath)
                for content_type in fs_obj.contentinfo.content_type_names:
                    query.add_qparam(content_type=content_type)

                fs_obj.openers_url = i18n_url('opener:list') + query.to_qs()
            else:
                fs_obj.openers_url = None

        for fs_obj in unfiltered_files:
            fs_obj.name = os.path.basename(fs_obj.path)
            fs_obj.relpath = os.path.relpath(fs_obj.path, relative_to)
            if fs_obj.name in self.META_FILES:
                meta[fs_obj.name] = fs_obj
            else:
                files.append(fs_obj)

        return (dirs, files, meta)

    def find(self, query):
        dirs = []
        files = []
        return (dirs, files, {})
