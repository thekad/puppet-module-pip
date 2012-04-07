# -*- mode: puppet; sh-basic-offset: 4; indent-tabs-mode: nil; coding: utf-8 -*-
# vim: tabstop=4 softtabstop=4 expandtab shiftwidth=4 fileencoding=utf-8

class pip {

    $pip_program = $operatingsystem ? {
        /(Ubuntu|Debian)/ => '/usr/bin/pip',
        /(Fedora|CentOS)/ => '/usr/bin/pip-python',
    }

    @package {
        'python-virtualenv':
            ensure => present,
            tag    => 'pip';
        'python-pip':
            ensure => present,
            tag    => 'pip';
    }

    case $operatingsystem {
        /(Ubuntu|Debian)/: {
            @package {
                'python-dev':
                    ensure => present,
                    tag    => 'pip';
            }
        }
        /(Fedora|CentOS)/: {
            @package {
                'python-devel':
                    ensure => present,
                    tag    => 'pip';
            }
        }
    }
}

