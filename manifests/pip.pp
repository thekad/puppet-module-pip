# -*- mode: puppet; sh-basic-offset: 4; indent-tabs-mode: nil; coding: utf-8 -*-
# vim: tabstop=4 softtabstop=4 expandtab shiftwidth=4 fileencoding=utf-8

define library::pip ($ensure='present', $package='', $virtualenv='') {

    include library

    $pkg = $package ? {
        ''      => $name,
        default => $package,
    }

    $full_name = $virtualenv ? {
        ''      => $pkg,
        default => "${virtualenv}::${pkg}",
    }

    Package <| tag == 'pip' |>

    Exec {
        logoutput => on_failure,
    }

    $pkg_regex = $ensure ? {
        /(present|installed|purged|absent|latest)/ => shellquote("^${pkg}=="),
        default                                    => shellquote("^${pkg}==${ensure}$"),
    }

    if $virtualenv {
        if !defined(Exec["virtualenv::setup::${virtualenv}"]) {
            exec {
                "virtualenv::setup::${virtualenv}":
                    command => "virtualenv --no-site-packages ${virtualenv}",
                    creates => "${virtualenv}/bin/pip",
                    require => Package['python-virtualenv'];
            }
        }
        $pip_program = "${virtualenv}/bin/pip"
    } else {
        $pip_program = "${library::pip_program}"
    }

    $check_version = "${pip_program} -q freeze 2>/dev/null | grep -iq ${pkg_regex}"

    $command = $ensure ? {
        /(absent|purged)/     => "${pip_program} uninstall -y ${pkg}",
        /(present|installed)/ => "${pip_program} install -M ${pkg}",
        'latest'              => "${pip_program} install -M -U ${pkg}",
        default               => "${pip_program} install -M ${pkg}==${ensure}",
    }

    exec {
        "pip::${full_name}::${ensure}":
            command => $command,
            unless  => $ensure ? {
                /(present|installed)/ => $check_version,
                /\d+.*/               => $check_version,
                default               => undef,
            },
            onlyif  => $ensure ? {
                /(absent|purged)/ => $check_version,
                default           => undef,
            },
            require => $virtualenv ? {
                ''      => Package['python-pip'],
                default => Exec["virtualenv::setup::${virtualenv}"],
            },
    }
}

