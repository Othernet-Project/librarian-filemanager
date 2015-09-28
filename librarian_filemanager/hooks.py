from .menuitems import FilesMenuItem
from .openers import OpenerRegistry


def initialize(supervisor):
    supervisor.exts.openers = OpenerRegistry()
    supervisor.exts.menuitems.register(FilesMenuItem)
