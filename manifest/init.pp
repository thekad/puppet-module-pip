class library::base {

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

