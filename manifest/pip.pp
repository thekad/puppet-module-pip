define library::pip ($ensure='present', $package='', $virtualenv='', $version='') {

    $pkg = $package ? {
        ''      => $name,
        default => $package,
    }

    $full_name = $virtualenv ? {
        ''      => $pkg,
        default => "${virtualenv}::${pkg}"
    }

    package {
        $library::pip_requires:
            ensure => installed,
            before => $virtualenv ? {
                ''      => undef,
                default => Exec["virtualenv::setup::${virtualenv}"],
            }
    }

    Exec {
        logoutput => on_failure,
    }

    $pkg_regex = $version ? {
        ''      => shellquote("^$pkg=="),
        default => shellquote("^${pkg}==${version}$"),
    }

    if $virtualenv {
        exec {
            "virtualenv::setup::${virtualenv}":
                command => "virtualenv --no-site-packages ${virtualenv}",
                creates => "${virtualenv}/bin/pip";
        }
        $pip_program = "${virtualenv}/bin/pip"
        $check_version = "${pip_program} -q freeze 2>/dev/null | grep -i ${pkg_regex} | cut -d= -f 3"
    } else {
        $pip_program = "${library::pip_program}"
        $check_version = "${pip_program} -q freeze 2>/dev/null | grep -i ${pkg_regex} | cut -d= -f 3"
    }

    case $ensure {
        'absent', 'purged': {
            $command = "${pip_program} uninstall ${pkg}"
        }
        'present', 'installed': {
            $command = "${pip_program} install ${pkg}"
        }
        default : {
            err("Invalid value for ensure (version has its own parameter): ${ensure}")
            fail('Invalid value for ensure')
        }
    }

    exec {
        "pip::exec::${full_name}":
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

