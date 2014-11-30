module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    def ovirt_host_callback
      logger.info "OvirtProvisionPlugin:: Running provision callback.."
      max_tries = 10;
      if self.is_ovirt_node?
        logger.info "OvirtProvisionPlugin:: Node provisioning is done."
      else
        while max_tries > 0 && self.ovirt_host? && self.status_installing?
          if (self.error?)
            logger.warn "OvirtProvisionPlugin:: Failed to run classes. Trying again (#{max_tries})"
            puppetrun!
            max_tries = max_tries - 1
          else
            begin
              logger.info "OvirtProvisionPlugin:: Running ovirt_host_callback on \"#{self.get_ovirt_host_name}\""
              host_id = self.get_ovirt_host_id
              client = self.get_ovirt_client
              client.reinstall_host("#{host_id}")
              logger.info "OvirtProvisionPlugin:: Sent reinstall command successfully"
            rescue OVIRT::OvirtException
              logger.warn "OvirtProvisionPlugin:: Failed to reinstall host. Trying again (#{max_tries})"
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
        logger.info "OvirtProvisionPlugin:: Provisioned ovirt node host"
        return true
      end
      return false
    end

    def ovirt_host?
      if self.get_ovirt_host_id
        logger.info "OvirtProvisionPlugin:: host related to oVirt"
        return true
      end
      return false
    end

    def status_installing?
      h = self.get_ovirt_host
      if h != "" && h.status.strip == "installing_os"
        logger.info "OvirtProvisionPlugin:: host in status installing"
        return true
      end
      return false
    end

    def get_ovirt_client
      begin
        cr_id = parameters.find_by_name("compute_resource_id").value
        cr = ComputeResource.find_by_id(cr_id)
        connection_opts = {}
        if not cr.public_key.blank?
          connection_opts[:datacenter_id] = cr.uuid
          connection_opts[:ca_cert_store] = OpenSSL::X509::Store.new.add_cert(OpenSSL::X509::Certificate.new(cr.public_key))
        end
        return OVIRT::Client.new("#{cr.user}", "#{cr.password}", "#{cr.url}", connection_opts)
      rescue OVIRT::OvirtException
        logger.error "OvirtProvisionPlugin:: compute resource id was not found"
        return false
      rescue NoMethodError
        logger.error "OvirtProvisionPlugin:: fail to read compute_rescource_id on host #{self.name}, id #{cr_id}"
        return false
      else
        logger.error "OvirtProvisionPlugin:: error occured during get_ovirt_client"
        return false
      end
    end

    def get_ovirt_host
      client = self.get_ovirt_client
      if not client
        logger.error "OvirtProvisionPlugin:: couldn't get ovirt_host"
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
        logger.error "OvirtProvisionPlugin:: host ovirt id was not found"
        return false
      rescue NoMethodError
        logger.error "OvirtProvisionPlugin:: fail to read host_ovirt_id on host #{self.name}"
        return false
      else
        logger.error "OvirtProvisionPlugin:: error occured during get_ovirt_host_id"
        return false
      end
    end
  end
end
