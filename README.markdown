Overview
========

Module to manage scripting language libraries for deployment in
standard and non-standard directories.

Planned:

* python (via pip)
* PEAR packages
* gems (maybe? via RVM)


Install
-------

Install in `<module_path>/library`


Python (pip)
------------

Example usage:

    include library

    library::pip {
        'bottle':
            ensure     => installed,
            virtualenv => '/usr/local/virtualenvs/proj1',
        'Django':
            ensure     => latest,
            virtualenv => '/usr/local/virtualens/proj1',
        'flask':
            ensure => '0.7.2';
    }


PHP (PEAR)
----------

Example usage:

    package {
        'php-mbstring':
            ensure => installed;
    }

    include library

    library::pear {
        'Proj1::Archive_Zip':
            package  => 'Archive_Zip',
            ensure   => latest,
            localdir => '/var/www/sites/proj1/pear',
        'File_Mogile':
            ensure   => '0.2.0',
            localdir => '/var/www/sites/proj1/pear',
            require  => Package['php-mbstring'];
        'System::Archive_Zip':
            package  => 'Archive_Zip',
            ensure   => absent;
    }


Disclaimer
==========

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
<http://sam.zoy.org/wtfpl/COPYING> for more details.

