Rails.application.routes.draw do

  get 'ovirt_hosts', :to => 'ovirt_provision_plugin/hosts#ovirt_hosts'

end
