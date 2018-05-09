# ovirt_provision_plugin

Ovirt provision plugin is responsible to finalize the host installation process started by oVirt engine.
The plugin is being used after the provision of the discovered host was completed successfully, by sending a
request via oVirt-engine Restful API to install the host that was just provisoined.

The entire Foreman provider integration is described [here](https://ovirt.org/develop/release-management/features/infra/foremanintegration/)

# How does it work

oVirt 3.5 allows to add foreman hosts provider to oVirt engine. This plugin is required to manage
new discovered host (which are recognized by foreman_discovery plugin).
When user adds new host from the discovered host by ovirt, the host is joined to cluster and foreman starts to provision
it regarding to the choosen host group configuration.
When the OS installation part ends, ovirt_provision_plugin recognizes it and sends API call to
ovirt-engine to reinstall the host id.

## Installation

### Red Hat, CentOS, Fedora, Scientific Linux (rpm)

* [Foreman: How to Install a Plugin](http://theforeman.org/manuals/latest/index.html#6.1InstallaPlugin)

Set up the repo as explained in the link above, then run

    # yum install ruby193-rubygem-ovirt_provision_plugin

### Bundle (gem)

Add the following to bundler.d/Gemfile.local.rb in your Foreman installation directory (/usr/share/foreman by default)

    $ gem 'ovirt_provision_plugin'

Then run `bundle install` and from the same directory.

## Compatibility

| oVirt | Foreman | Plugin |
| ---------------:| ---------------:| --------------:|
| >= 4.0 | >= 1.6         | 2.0.0 |
| < 4.0 | >= 1.6         | 1.0.2 |

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2014 Yaniv Bronhaim

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

