from bottle import request

from librarian_content.library.metadata import CONTENT_TYPE_EXTENSIONS
from librarian_core.contrib.templates.decorators import template_helper


class OpenerRegistry(object):

    def __init__(self):
        self.extensions = dict()
        self.content_types = dict()
        self.labels = dict()
        self.openers = dict()

    def register(self, opener_id, label, route, content_type):
        """Register an opener to be associated with one or more extensions.
        :param opener_id:     unique string identifying the opener
        :param label:         label to be show as name of opener
        :param route:         function that should return a dict with any data
                              that could be needed by the opener's template
        :param content_type:  string: content type name that the opener handles
        """
        if opener_id in self.openers:
            msg = "Opener with id: {0} already exists.".format(opener_id)
            raise ValueError(msg)

        self.openers[opener_id] = route
        self.labels[opener_id] = label

        self.content_types.setdefault(content_type, [])
        self.content_types[content_type].append(opener_id)

        for ext in CONTENT_TYPE_EXTENSIONS[content_type]:
            self.extensions.setdefault(ext, [])
            self.extensions[ext].append(opener_id)

    def filter_by(self, content_type=None, extension=None):
        if content_type:
            return self.content_types.get(content_type, [])
        return self.extensions.get(extension, [])

    def first(self, content_type=None, extension=None):
        openers = self.filter_by(content_type=content_type,
                                 extension=extension)
        if not openers:
            return None
        return openers[0]

    def get(self, opener_id):
        return self.openers[opener_id]

    def label(self, opener_id):
        return self.labels[opener_id]


@template_helper
def first_opener(meta):
    content_type = meta.content_type_names[0]
    return request.app.supervisor.exts.openers.first(content_type=content_type)
