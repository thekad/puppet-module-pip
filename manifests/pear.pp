# -*- mode: puppet; sh-basic-offset: 4; indent-tabs-mode: nil; coding: utf-8 -*-
# vim: tabstop=4 softtabstop=4 expandtab shiftwidth=4 fileencoding=utf-8

define library::pear($ensure='present', $package='', $localdir='') {

    $pkg = $package ? {
        ''      => $name,
        default => $package,
    }

    $full_name = $localdir ? {
        ''      => $pkg,
        default => "${localdir}::${pkg}",
    }

    Package <| tag == 'pear' |>

    Exec {
        logoutput => on_failure,
    }

    if $localdir {
        if !defined(Exec["localdir::setup::${localdir}"]) {

            file {
                "${localdir}":
                    ensure => directory,
                    mode   => 0755;
                "${localdir}/fix_registry.sh":
                    content => template("library/fix_registry.sh.erb"),
                    mode    => 0755,
                    require => File["${localdir}"];
            }

            exec {
                "localdir::setup::${localdir}":
                    command => "${library::pear_program} config-create ${localdir} ${localdir}/.pearrc",
                    creates => "${localdir}/.pearrc",
                    require => [
                        Package['php-pear'],
                        File["${localdir}"],
                    ],
                    notify  => Exec["localdir::setup::${localdir}::fix_registry"];
                "localdir::setup::${localdir}::fix_registry":
                    command     => "${localdir}/fix_registry.sh",
                    refreshonly => true,
                    require     => File["${localdir}/fix_registry.sh"];
            }
        }
        $pear_program = "${library::pear_program} -c ${localdir}/.pearrc"
    } else {
        $pear_program = "${library::pear_program}"
    }

    $pkg_filter = $ensure ? {
            /(present|installed|purged|absent|latest)/ => "${pkg}",
            default                                    => "${pkg} == ${ensure}",
    }

    $check_version = "${pear_program} shell-test ${pkg_filter}"

    $command = $ensure ? {
        /(absent|purged)/     => "${pear_program} uninstall ${pkg}",
        /(present|installed)/ => "${pear_program} install -o ${pkg}",
        'latest'              => "${pear_program} upgrade -o ${pkg}",
        default               => "${pear_program} install -o ${pkg}-${ensure}",
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
            require => $localdir ? {
                ''      => Package['php-pear'],
                default => [
                    Package['php-pear'],
                    Exec["localdir::setup::${localdir}::fix_registry"],
                ],
            };
    }
}

