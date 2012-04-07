# -*- mode: puppet; sh-basic-offset: 4; indent-tabs-mode: nil; coding: utf-8 -*-
# vim: tabstop=4 softtabstop=4 expandtab shiftwidth=4 fileencoding=utf-8

define pip::lib ($ensure='present', $package='', $virtualenv='', $vcsurl='', $extraindex='') {

    if $package and $vcsurl {
        err('You have to specify package or vcsurl, not both')
        fail('You have to specify package or vcsurl')
    }

    $pkg = $package ? {
        ''      => $name,
        default => $package,
    }

    $full_name = $virtualenv ? {
        ''      => $pkg,
        default => "${virtualenv}::${pkg}",
    }

    $extra = $extraindex ? {
        ''      => '',
        default => "--extra-index-url='${extraindex}'",
    }

    Package <| tag == 'pip' |>

    Exec {
        logoutput => on_failure,
    }

    $pkg_regex = $vcsurl ? {
        ''      => $ensure ? {
            /(present|installed|purged|absent|latest)/ => shellquote("^${pkg}=="),
            default                                    => shellquote("^${pkg}==${ensure}$"),
        },
        default => "^${pkg}==",
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
        $pip_program = "${pip::pip_program}"
    }

    $check_version = "${pip_program} -q freeze 2>/dev/null | /bin/grep -iq ${pkg_regex}"

    $command = $vcsurl ? {
        ''      => $ensure ? {
            /(absent|purged)/     => "${pip_program} uninstall -y ${pkg}",
            /(present|installed)/ => "${pip_program} install ${extra} -M ${pkg}",
            'latest'              => "${pip_program} install ${extra} -M -U ${pkg}",
            default               => "${pip_program} install ${extra} -M -I ${pkg}==${ensure}",
        },
        default => $ensure ? {
            /(absent|purged)/ => "${pip_program} uninstall -y ${pkg}",
            default           => "${pip_program} install -e ${vcsurl}",
        },
    }

    exec {
        "${full_name}::${ensure}":
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

