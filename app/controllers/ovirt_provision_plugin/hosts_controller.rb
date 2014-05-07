module OvirtProvisionPlugin

  # Example: Plugin's HostsController inherits from Foreman's HostsController
  class HostsController < ::HostsController

    # change layout if needed
    # layout 'ovirt_provision_plugin/layouts/new_layout'

    def ovirt_hosts
      # automatically renders view/ovirt_provision_plugin/hosts/new_action
      logger.debug "loading page"
    end

  end
end
