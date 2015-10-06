from functools import partial

from .menuitems import FilesMenuItem
from .openers import OpenerRegistry
from .tasks import check_new_dirinfo


def initialize(supervisor):
    supervisor.exts.openers = OpenerRegistry()
    supervisor.exts.menuitems.register(FilesMenuItem)
    supervisor.events.subscribe('FILE_ADDED', partial(check_new_dirinfo,
                                                      supervisor))
