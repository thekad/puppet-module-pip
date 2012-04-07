Overview
========

Module to manage Python pip libraries in standard and non-standard directories.


Install
-------

Install in `<module_path>/pip`


Python (pip)
------------

Example usage:

    include pip

    pip::lib {
        'bottle':
            ensure     => installed,
            virtualenv => '/usr/local/virtualenvs/proj1',
        'Django':
            ensure     => latest,
            virtualenv => '/usr/local/virtualens/proj1',
        'flask':
            ensure => '0.7.2';
    }


Disclaimer
==========

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
<http://sam.zoy.org/wtfpl/COPYING> for more details.

