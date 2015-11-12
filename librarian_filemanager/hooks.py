from functools import partial

from .menuitems import FilesMenuItem
from .openers import OpenerRegistry
from .tasks import check_dirinfo


def initialize(supervisor):
    supervisor.exts.openers = OpenerRegistry()
    supervisor.exts.menuitems.register(FilesMenuItem)
    supervisor.exts.events.subscribe('FS_EVENT', partial(check_dirinfo,
                                                         supervisor))
