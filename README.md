# ovirt_provision_plugin

Ovirt provision plugin sends API request to oVirt management to reinstall host id after discovered hosts are first provisioned
by oVirt engine (Using foreman provider integration).

# How does it work

oVirt 3.5 allows to add foreman hosts provider to oVirt engine. This plugin is required to manage
new discovered host (which are recognized by foreman_discovery plugin).
When user adds new host from the discovered host by ovirt, the host is joined to cluster and foreman starts to provision
it regarding to the choosen host group configuration.
When the OS installation part ends, ovirt_provision_plugin recognizes it and sends API call to
ovirt-engine to reinstall the host id.

## Installation

yum install ruby193-rubygem-ovirt_provision_plugin

[TODO: remove this section when plugin gets to official repo]
Currently you can use:
http://yum.theforeman.org/plugins/nightly/el6/x86_64/ruby193-rubygem-ovirt_provision_plugin-0.0.1-1.el6.noarch.rpm

The plugin requires also rbovirt updates, which can be found in:
http://yum.theforeman.org/nightly/el6/x86_64/ruby193-rubygem-rbovirt-0.0.28-1.el6.noarch.rpm

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

