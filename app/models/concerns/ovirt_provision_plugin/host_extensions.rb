module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    def ovirt_host_callback
      logger.debug "OvirtProvisionPlugin:: Running provision callback.."
      max_tries = 10;
      if self.is_ovirt_node?
        logger.debug "OvirtProvisionPlugin:: Node provisioning is done."
      else
        while max_tries > 0 && self.ovirt_host? && self.status_installing?
          if (self.error?)
            logger.debug "OvirtProvisionPlugin:: Failed to run classes. Trying again (#{max_tries})"
            puppetrun!
            max_tries = max_tries - 1
          else
            begin
              logger.debug "OvirtProvisionPlugin:: Running ovirt_host_callback on \"#{self.get_ovirt_host_name}\""
              host_id = self.get_ovirt_host_id
              client = self.get_ovirt_client
              client.reinstall_host("#{host_id}")
              logger.debug "OvirtProvisionPlugin:: Sent reinstall command successfully"
            rescue OVIRT::OvirtException
              logger.debug "OvirtProvisionPlugin:: Failed to reinstall host. Trying again (#{max_tries})"
              puppetrun!
              max_tries = max_tries - 1
            end
          end
        end
      end
    end

    def is_ovirt_node?
      is_ovirt_node = self.operatingsystem.name == "oVirt-Node" or self.operatingsystem.name == "RHEV-H"
      if is_ovirt_node
        logger.debug "OvirtProvisionPlugin:: Provisioned ovirt node host"
        return true
      end
      return false
    end

    def ovirt_host?
      if self.get_ovirt_host_id
        logger.debug "OvirtProvisionPlugin:: host related to oVirt"
        return true
      end
      return false
    end

    def status_installing?
      h = self.get_ovirt_host
      if h != "" && h.status.strip == "installing_os"
        logger.debug "OvirtProvisionPlugin:: host in status installing"
        return true
      end
      return false
    end

    def get_ovirt_client
        begin
            cr_id = parameters.find_by_name("compute_resource_id").value
            cr = ComputeResource.find_by_id(cr_id)
            return OVIRT::Client.new("#{cr.user}", "#{cr.password}", "#{cr.url}")
        rescue OVIRT::OvirtException
            logger.debug "OvirtProvisionPlugin:: compute resource id was not found"
            return false
        rescue NoMethodError
            logger.debug "OvirtProvisionPlugin:: fail to read compute_rescource_id on host #{self.name}, id #{cr_id}"
            return false
        else
            logger.debug "OvirtProvisionPlugin:: error occured during get_ovirt_client"
            return false
        end
    end

    def get_ovirt_host
        client = self.get_ovirt_client
        if not client
            logger.debug "OvirtProvisionPlugin:: couldn't get ovirt_host"
            return ""
        else
            return client.host(get_ovirt_host_id)
        end
    end

    def get_ovirt_host_name
        h = self.get_ovirt_host
        if not h
            return ""
        else
            return h.name
        end
    end

    def get_ovirt_host_id
        begin
            return self.parameters.find_by_name("host_ovirt_id").value
        rescue OVIRT::OvirtException
            logger.debug "OvirtProvisionPlugin:: host ovirt id was not found"
            return false
        rescue NoMethodError
            logger.debug "OvirtProvisionPlugin:: fail to read host_ovirt_id on host #{self.name}"
            return false
        else
            logger.debug "OvirtProvisionPlugin:: error occured during get_ovirt_host_id"
            return false
        end
    end
  end
end
