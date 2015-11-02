import logging
import os
import re

from bottle_utils.common import to_bytes, to_unicode

from librarian_core.contrib.cache.utils import generate_key


class DirInfo(object):
    FILENAME = '.dirinfo'
    CACHE_KEY_TEMPLATE = u'dirinfo_{0}'
    NO_LANGUAGE = ''
    ENTRY_REGEX = re.compile(r'(\w+)\[(\w+)\]')

    def __init__(self, supervisor, path, data=None):
        self.supervisor = supervisor
        self.path = path
        self._info = data or dict()

    def get(self, language, key, default=None):
        try:
            return self._info[language][key]
        except KeyError:
            try:
                value = self._info[self.NO_LANGUAGE][key]
            except KeyError:
                return default
            else:
                return default if value is None else value

    def read_file(self):
        """Read dirinfo file from disk."""
        info_file_path = os.path.join(self.path, self.FILENAME)
        if os.path.exists(info_file_path):
            try:
                with open(info_file_path, 'r') as info_file:
                    info = info_file.readlines()

                for line in info:
                    key, value = line.split('=')
                    match = self.ENTRY_REGEX.match(key)
                    if match:
                        (key, language) = match.groups()
                    else:
                        language = self.NO_LANGUAGE

                    self._info.setdefault(language, {})
                    self._info[language][key] = to_unicode(value).strip()
            except Exception:
                self._info = dict()
                msg = ".dirinfo reading of {0} failed.".format(self.path)
                logging.exception(msg)

    def read_db(self):
        """Read dirinfo data from database."""
        db = self.supervisor.exts.databases.files
        query = db.Select(sets='dirinfo', where='path = ?')
        db.query(query, self.path)
        entries = db.results
        if entries:
            for entry in entries:
                language = entry['language'] or self.NO_LANGUAGE
                self._info[language] = dict((key, entry[key])
                                            for key in entry.keys()
                                            if key not in ('path', 'language'))
            return True

        return False

    def save_to_db(self):
        """Store dirinfo data structure in database."""
        db = self.supervisor.exts.databases.files
        info = self._info or {self.NO_LANGUAGE: {}}
        for language, data in info.items():
            to_write = dict(path=self.path, language=language)
            to_write.update(data)
            query = db.Replace('dirinfo', cols=to_write.keys())
            db.query(query, **to_write)

    def get_data(self):
        return self._info

    @classmethod
    def get_cache_key(cls, path):
        generated = generate_key(path)
        return to_bytes(cls.CACHE_KEY_TEMPLATE.format(generated))

    @classmethod
    def from_file(cls, supervisor, path):
        """Read dirinfo from disk, store it in database and put the retrieved
        in the cache."""
        dirinfo = cls(supervisor, path)
        dirinfo.read_file()
        dirinfo.save_to_db()
        supervisor.exts.cache.set(cls.get_cache_key(path), dirinfo.get_data())
        return dirinfo

    @classmethod
    def from_db(cls, supervisor, path):
        """Read dirinfo from database and put the retrieved in the cache. If
        no entries are found in the database, a background task will be
        scheduled to read the file from disk."""
        # attempt reading from cache first
        if supervisor.exts.is_installed('cache'):
            key = cls.get_cache_key(path)
            data = supervisor.exts.cache.get(key)
            if data:
                return cls(supervisor, path, data=data)
        # if not in cache, get it from the database
        dirinfo = cls(supervisor, path)
        if dirinfo.read_db():
            supervisor.exts.cache.set(cls.get_cache_key(path),
                                      dirinfo.get_data())
        else:
            supervisor.exts.tasks.schedule(DirInfo.from_file,
                                           args=(supervisor, path))

        return dirinfo
