import os
import mimetypes

from librarian_content.library import metadata
from bottle_utils.common import to_unicode

from .dirinfo import DirInfo


class Manager(object):

    def __init__(self, supervisor):
        self.supervisor = supervisor
        self.fsal_client = self.supervisor.exts.fsal
        conf = supervisor.config
        self.META_FILES = [DirInfo.FILENAME] + conf['library.metadata']

    def get_dirinfos(self, paths):
        return DirInfo.from_db(self.supervisor, paths)

    def get_contentinfos(self, paths):
        return metadata.Meta.from_db(self.supervisor, paths)

    def _extend_dirs(self, dirs):
        dirpaths = [fs_obj.rel_path for fs_obj in dirs]
        dirinfos = self.get_dirinfos(dirpaths)
        contentinfos = self.get_contentinfos(dirpaths)
        for fs_obj in dirs:
            fs_obj.dirinfo = dirinfos[fs_obj.rel_path]
            fs_obj.contentinfo = contentinfos.get(fs_obj.rel_path)
        return dirs

    def _extend_file(self, fs_obj):
        mimetype, encoding = mimetypes.guess_type(fs_obj.rel_path)
        fs_obj.mimetype = mimetype
        fs_obj.parent = to_unicode(
            os.path.basename(os.path.dirname(fs_obj.path)))
        return fs_obj

    def _process_listing(self, dirs, unfiltered_files):
        meta = {}
        files = []
        self._extend_dirs(dirs)
        for fs_obj in unfiltered_files:
            self._extend_file(fs_obj)
            if fs_obj.name in self.META_FILES:
                meta[fs_obj.name] = fs_obj
            else:
                files.append(fs_obj)
        return (dirs, files, meta)

    def list(self, path):
        (success, dirs, files) = self.fsal_client.list_dir(path)
        (dirs, files, meta) = self._process_listing(dirs, files)
        return (success, dirs, files, meta)

    def list_descendants(self, path, span):
        (success, dirs, files) = self.fsal_client.list_descendants(path, span)
        (dirs, files, meta) = self._process_listing(dirs, files)
        return (success, dirs, files, meta)

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
