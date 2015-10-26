import os
import mimetypes

from bottle_utils import html
from bottle_utils.i18n import i18n_url

from librarian_content.library import metadata
from librarian_content.library.archive import Archive

from .dirinfo import DirInfo


class Manager(object):

    def __init__(self, supervisor):
        self.supervisor = supervisor
        self.fsal_client = self.supervisor.exts.fsal
        conf = supervisor.config
        self.archive = Archive.setup(conf['library.backend'],
                                     supervisor.exts.fsal,
                                     supervisor.exts.databases.content,
                                     contentdir=conf['library.contentdir'],
                                     meta_filenames=conf['library.metadata'])
        self.META_FILES = [DirInfo.FILENAME] + conf['library.metadata']

    def get_dirinfo(self, path):
        # return DirInfo.from_db(self.supervisor, path)
        # FIXME: This is a temprary workaround while the backend is being
        # worked on. VERY SLOW!!!
        return DirInfo.from_file(self.supervisor, path)

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

    def _extend_dir(self, fs_obj):
        fs_obj.dirinfo = self.get_dirinfo(fs_obj.path)
        fs_obj.contentinfo = self.get_contentinfo(fs_obj.rel_path)
        if fs_obj.contentinfo:
            query = html.QueryDict()
            query.add_qparam(path=fs_obj.rel_path)
            for content_type in fs_obj.contentinfo.content_type_names:
                query.add_qparam(content_type=content_type)

            fs_obj.openers_url = i18n_url('opener:list') + query.to_qs()
        else:
            fs_obj.openers_url = None
        return fs_obj

    def _extend_file(self, fs_obj):
        mimetype, encoding = mimetypes.guess_type(fs_obj.rel_path)
        fs_obj.mimetype = mimetype
        return fs_obj

    def _process_listing(self, dirs, unfiltered_files):
        meta = {}
        files = []
        for fs_obj in dirs:
            self._extend_dir(fs_obj)
        for fs_obj in unfiltered_files:
            self._extend_file(fs_obj)
            if fs_obj.name in self.META_FILES:
                meta[fs_obj.name] = fs_obj
            else:
                files.append(fs_obj)
        return (dirs, files, meta)

    def list(self, path):
        (dirs, files) = self.fsal_client.list_dir(path)
        return self._process_listing(dirs, files)

    def search(self, query):
        (dirs, unfiltered_files, is_match) = self.fsal_client.search(query)
        (dirs, files, meta) = self._process_listing(dirs, unfiltered_files)
        return (dirs, files, meta, is_match)

    def isdir(self, path):
        return self.fsal_client.isdir(path)

    def isfile(self, path):
        return self.fsal_client.isfile(path)

    def exists(self, path):
        return self.fsal_client.exists(path)

    def remove(self, path):
        return self.fsal_client.remove(path)

    def move(self, src, dst):
        return self.fsal_client.move(src, dst)

    def copy(self, src, dst):
        return self.fsal_client.copy(src, dst)
