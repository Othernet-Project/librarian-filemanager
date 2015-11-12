import os

from .dirinfo import DirInfo


def check_dirinfo(supervisor, event):
    if os.path.basename(event.src) == DirInfo.FILENAME:
        if event.event_type == 'created':
            DirInfo.from_file(supervisor, event.src)
        elif event.event_type == 'deleted':
            DirInfo.from_db(supervisor, event.src).delete()
