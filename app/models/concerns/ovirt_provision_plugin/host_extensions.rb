require 'ovirtsdk4'

module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    def ovirt_host_callback
      logger.info "OvirtProvisionPlugin:: Running provision callback.."
      max_tries = 10;
      if self.is_ovirt_node?
        logger.info "OvirtProvisionPlugin:: Node provisioning is done."
      else
        client = nil
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
              client.system_service.hosts_service.host_service(host_id).install(
                ssh: {
                  authentication_method: OvirtSDK4::SshAuthenticationMethod::PUBLICKEY
                },
                host: {
                  override_iptables: false
                }
              )
              logger.info "OvirtProvisionPlugin:: Sent reinstall command successfully"
            rescue OvirtSDK4::Error
              logger.warn "OvirtProvisionPlugin:: Failed to reinstall host. Trying again (#{max_tries})"
              puppetrun!
              max_tries = max_tries - 1
            ensure
              client.close if client
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
        connection_opts = {
          :url      => cr.url,
          :username => cr.username,
          :password => cr.password,
        }
        if cr.public_key.blank?
          connection_opts[:insecure] = true
        else
          connection_opts[:ca_certs] = [cr.public_key]
        end
        OvirtSDK4::Connection.new(connection_opts)
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
        connection.system_service.hosts_service.host_service(get_ovirt_host_id).get
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
