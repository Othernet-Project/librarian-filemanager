from .manager import DirInfo, DIRINFO_FILENAME


def check_new_dirinfo(supervisor, fsobj):
    if fsobj.name == DIRINFO_FILENAME:
        DirInfo.from_file(supervisor, fsobj.path)
