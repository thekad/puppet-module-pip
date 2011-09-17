# -*- mode: puppet; sh-basic-offset: 4; indent-tabs-mode: nil; coding: utf-8 -*-
# vim: tabstop=4 softtabstop=4 expandtab shiftwidth=4 fileencoding=utf-8

define library::pip ($ensure='present', $package='', $virtualenv='', $version='') {

    $pkg = $package ? {
        ''      => $name,
        default => $package,
    }

    $full_name = $virtualenv ? {
        ''      => $version ? {
            ''      => $pkg,
            default => "${pkg}==${version}",
        },
        default => $version ? {
            ''      => "${virtualenv}::${pkg}",
            default => "${virtualenv}::${pkg}==${version}",
        }
    }

    package {
        $library::pip_requires:
            ensure => installed;
    }

    Exec {
        logoutput => on_failure,
    }

    $pkg_regex = $version ? {
        ''      => shellquote("^${pkg}=="),
        default => shellquote("^${pkg}==${version}$"),
    }

    if $virtualenv {
        exec {
            "virtualenv::setup::${virtualenv}":
                command => "virtualenv --no-site-packages ${virtualenv}",
                creates => "${virtualenv}/bin/pip",
                require => Package[$library::pip_requires];
        }
        $pip_program = "${virtualenv}/bin/pip"
        $check_version = "${pip_program} -q freeze 2>/dev/null | grep -iq ${pkg_regex}"
    } else {
        $pip_program = "${library::pip_program}"
        $check_version = "${pip_program} -q freeze 2>/dev/null | grep -iq ${pkg_regex}"
    }

    case $ensure {
        'absent', 'purged': {
            $command = "${pip_program} uninstall ${pkg}"
        }
        'present', 'installed': {
            $command = $version ? {
                ''      => "${pip_program} install -M ${pkg}",
                default => "${pip_program} install -M ${pkg}==${version}",
            }
        }
        'latest': {
            $command = "${pip_program} install -M -U ${pkg}"
        }
        default : {
            err("Invalid value for ensure (version has its own parameter): ${ensure}")
            fail('Invalid value for ensure')
        }
    }

    exec {
        "pip::${full_name}":
            command => $command,
            unless  => $ensure ? {
                /(present|installed)/ => $check_version,
                default               => undef,
            },
            onlyif  => $ensure ? {
                /(absent|purged)/ => $check_version,
                default           => undef,
            },
    }
}

