=====================
librarian-filemanager
=====================

**END OF LIFE:** This package has been merged into the development branch of
the librarian package and will not be maintained anymore.

The filemanager component provides a GUI for browsing and managing the content
library (similar to conventional file managers), and an API for registering
openers of specific content types, which are librarian_'s equivalent of file
type associations.

Installation
------------

The component has the following dependencies:

- librarian-core_
- librarian-content_

To enable this component, add it to the list of components in librarian_'s
`config.ini` file, e.g.::

    [app]
    +components =
        librarian_filemanager

And to make the menuitem show up::

    [menu]
    +main =
        files

Development
-----------

In order to recompile static assets, make sure that compass_ and coffeescript_
are installed on your system. To perform a one-time recompilation, execute::

    make recompile

To enable the filesystem watcher and perform automatic recompilation on changes,
use::

    make watch

.. _librarian: https://github.com/Outernet-Project/librarian
.. _librarian-core: https://github.com/Outernet-Project/librarian-core
.. _librarian-content: https://github.com/Outernet-Project/librarian-content
.. _compass: http://compass-style.org/
.. _coffeescript: http://coffeescript.org/
