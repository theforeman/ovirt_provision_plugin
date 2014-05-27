module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    def ovirt_host_callback
      logger.debug "OvirtProvisionPlugin:: Running provision callback.."
      # TODO: check if host_ready? relevant to this condition
      if self.ovirt_host? && self.status_installing? && (not self.is_ovirt_node?)
        logger.debug "OvirtProvisionPlugin:: Running ovirt_host_callback on \"#{self.get_ovirt_host_name}\""
        host_id = self.get_ovirt_host_id
        client = self.get_ovirt_client
        client.reinstall_host("#{host_id}")
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

    def host_ready?
      fail(Foreman::Exception, "Latest Puppet Run Contains Failures for Host: #{id}") if failed > 0
      if self.skipped == 0 && self.pending == 0
        logger.debug "OvirtProvisionPlugin:: host ready"
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
      if h && h.status.strip == "installing_os"
        logger.debug "OvirtProvisionPlugin:: host in status installing"
        return true
      end
      return false
    end

    def get_ovirt_client
        begin
            cr = ComputeResource.find_by_id(parameters.find_by_name("compute_resource_id").value)
            return OVIRT::Client.new("#{cr.user}", "#{cr.password}", "#{cr.url}")
        rescue OVIRT::OvirtException
            logger.debug "OvirtProvisionPlugin:: compute resource id was not found"
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
        else
            logger.debug "OvirtProvisionPlugin:: error occured during get_ovirt_host_id"
            return false
        end
    end
  end
end
