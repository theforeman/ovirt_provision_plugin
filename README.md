# OvirtProvisionPlugin

This plugin monitors oVirt provision for new host and perform related API calls to oVirt Engine.

# How does it work

oVirt 3.5 allows to add foreman hosts to oVirt-engine by its user interface. This plugin helps to manage
new discovered host (which are recognized by foreman_discovery plugin).
When user adds new host from the discovered host, the host joins to oVirt cluster and get installed.
When the OS installation part ends, OvirtProvisionPlugin sends API call to ovirt-engine to deploy the host, which
means to install all that needed to provide vms manipulation on host (called deployed host).

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Usage

Adding the plugin to foreman gem will add automatically to the provision host flow the registration to oVirt cluster.

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

