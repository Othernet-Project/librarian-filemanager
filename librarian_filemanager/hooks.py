from functools import partial

from .menuitems import FilesMenuItem
from .openers import OpenerRegistry
from .tasks import check_new_dirinfo


def initialize(supervisor):
    supervisor.exts.openers = OpenerRegistry()
    supervisor.exts.menuitems.register(FilesMenuItem)
    wrapped = partial(check_new_dirinfo, supervisor)
    wrapped.__module__ = check_new_dirinfo.__module__
    supervisor.events.subscribe('FILE_ADDED', wrapped)
