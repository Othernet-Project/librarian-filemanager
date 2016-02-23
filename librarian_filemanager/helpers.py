from bottle import request

from librarian_content.library.facets.facets import Facets

def get_facets(path):
    supervisor = request.app.supervisor
    facets = Facets.from_db(supervisor, (path,))
    return facets.get(path, None)

