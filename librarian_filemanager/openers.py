

class OpenerRegistry(object):

    def __init__(self):
        self.associations = dict()
        self.openers = dict()

    def register(self, opener_id, opener_route, extensions):
        """Register an opener to be associated with one or more extensions.
        :param opener_id:     unique string identifying the opener
        :param opener_route:  function that should return a dict with any data
                              that could be needed by the opener's template
        :param extensions:    a list of one or more file extensions
        """
        if opener_id in self.openers:
            msg = "Opener with id: {0} already exists.".format(opener_id)
            raise ValueError(msg)

        self.openers[opener_id] = opener_route
        for ext in extensions:
            self.associations.setdefault(ext, [])
            self.associations[ext].append(opener_id)

    def filter_for(self, ext):
        return self.associations.get(ext, [])

    def first(self, ext):
        openers = self.filter_for(ext)
        if not openers:
            return None
        return openers[0]

    def get(self, opener_id):
        return self.openers[opener_id]
