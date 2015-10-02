from librarian_content.library.metadata import CONTENT_TYPE_EXTENSIONS


class OpenerRegistry(object):

    def __init__(self):
        self.extensions = dict()
        self.content_types = dict()
        self.openers = dict()

    def register(self, opener_id, opener_route, content_type):
        """Register an opener to be associated with one or more extensions.
        :param opener_id:     unique string identifying the opener
        :param opener_route:  function that should return a dict with any data
                              that could be needed by the opener's template
        :param content_type:  string: content type name that the opener handles
        """
        if opener_id in self.openers:
            msg = "Opener with id: {0} already exists.".format(opener_id)
            raise ValueError(msg)

        self.openers[opener_id] = opener_route

        self.content_types.setdefault(content_type, [])
        self.content_types[content_type].append(opener_id)

        for ext in CONTENT_TYPE_EXTENSIONS[content_type]:
            self.extensions.setdefault(ext, [])
            self.extensions[ext].append(opener_id)

    def for_extension(self, ext):
        return self.extensions.get(ext, [])

    def for_content_type(self, content_type):
        return self.content_types.get(content_type, [])

    def first_extension(self, ext):
        openers = self.for_extension(ext)
        if not openers:
            return None
        return openers[0]

    def first_content_type(self, content_type):
        openers = self.for_content_type(content_type)
        if not openers:
            return None
        return openers[0]

    def get(self, opener_id):
        return self.openers[opener_id]
