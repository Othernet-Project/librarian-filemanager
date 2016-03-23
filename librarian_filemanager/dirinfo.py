import logging
import os
import re

from bottle_utils.common import to_unicode

from librarian_content.library.base import CDFObject


class DirInfo(CDFObject):
    DATABASE_NAME = 'files'
    TABLE_NAME = 'dirinfo'
    CACHE_KEY_TEMPLATE = u'dirinfo_{0}'
    FILENAME = '.dirinfo'
    ENTRY_REGEX = re.compile(r'(\w+)\[(\w+)\]')
    NO_LANGUAGE = ''

    def get(self, language, key, default=None):
        try:
            return self._data[language][key]
        except KeyError:
            try:
                value = self._data[self.NO_LANGUAGE][key]
            except KeyError:
                return default
            else:
                return default if value is None else value

    def store(self):
        """Store dirinfo data structure in database."""
        db = self.supervisor.exts.databases[self.DATABASE_NAME]
        data = self._data or {self.NO_LANGUAGE: {}}
        for language, info in data.items():
            to_write = dict(path=self.path, language=language)
            to_write.update(info)
            query = db.Replace(self.TABLE_NAME,
                               constraints=['path', 'language'],
                               cols=to_write.keys())
            db.execute(query, to_write)

    def delete(self):
        db = self.supervisor.exts.databases[self.DATABASE_NAME]
        query = db.Delete(self.TABLE_NAME, where='path = %s')
        db.execute(query, (self.path,))
        self.supervisor.exts.cache.delete(self.get_cache_key(self.path))

    def read_file(self):
        """Read dirinfo file from disk."""
        info_file_path = os.path.join(self.path, self.FILENAME)
        fsal = self.supervisor.exts.fsal
        if fsal.exists(info_file_path):
            try:
                with fsal.open(info_file_path, 'r') as info_file:
                    info = info_file.readlines()

                for line in info:
                    key, value = line.split('=')
                    match = self.ENTRY_REGEX.match(key)
                    if match:
                        (key, language) = match.groups()
                    else:
                        language = self.NO_LANGUAGE

                    self._data.setdefault(language, {})
                    self._data[language][key] = to_unicode(value).strip()
            except Exception:
                self._data = dict()
                msg = ".dirinfo reading of {0} failed.".format(self.path)
                logging.exception(msg)

    @classmethod
    def fetch(cls, db, paths):
        query = db.Select(sets=cls.TABLE_NAME, where=db.sqlin('path', paths))
        for row in db.fetchiter(query, paths):
            if row:
                raw_data = cls.row_to_dict(row)
                language = raw_data.pop('language', None) or cls.NO_LANGUAGE
                yield (raw_data.pop('path'), {language: raw_data})
