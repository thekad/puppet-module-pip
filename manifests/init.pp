# -*- mode: puppet; sh-basic-offset: 4; indent-tabs-mode: nil; coding: utf-8 -*-
# vim: tabstop=4 softtabstop=4 expandtab shiftwidth=4 fileencoding=utf-8

class library {

    $pip_program = $operatingsystem ? {
        /(Ubuntu|Debian)/ => '/usr/bin/pip',
        /(Fedora|CentOS)/ => '/usr/bin/pip-python',
    }

    $pip_requires = $operatingsystem ? {
        /(Ubuntu|Debian)/ => [
            'python-dev',
            'python-virtualenv',
            'python-pip',
        ],
        /(Fedora|CentOS)/ => [
            'python-devel',
            'python-virtualenv',
            'python-pip',
        ],
    }
}

