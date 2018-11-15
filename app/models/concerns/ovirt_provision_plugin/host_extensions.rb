require 'ovirtsdk4'

module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    def ovirt_host_callback
      logger.info "OvirtProvisionPlugin:: Running provision callback.."
      return unless ovirt_host?

      return if ovirt_node?

      max_tries = 10
      while max_tries.positive?
        client = ovirt_client
        if client.nil?
          logger.warn "OvirtProvisionPlugin:: Failed to connect to ovirt-engine"
          max_tries -= 1
          next
        end

        ovirt_host = host_for_installing(client)
        unless ovirt_host
          client.close
          return
        end

        unless errors.empty?
          client.close
          logger.warn "OvirtProvisionPlugin:: Failed to run classes. Trying again (#{max_tries})"
          puppetrun!
          max_tries -= 1
          next
        end

        begin
          logger.info "OvirtProvisionPlugin:: Running ovirt_host_callback on \"#{ovirt_host.name}\""
          host_service(client).install(:ssh => { authentication_method: OvirtSDK4::SshAuthenticationMethod::PUBLICKEY })
          logger.info "OvirtProvisionPlugin:: Sent reinstall command successfully"
          return
        rescue OvirtSDK4::Error
          logger.warn "OvirtProvisionPlugin:: Failed to reinstall host. Trying again (#{max_tries})"
          puppetrun!
          max_tries -= 1
        ensure
          client.close
        end
      end
    end

    def host_for_installing(client)
      begin
        ovirt_host = host_service(client).get
        unless status_installing?(ovirt_host)
          return nil
        end
      rescue OvirtSDK4::Error
        logger.warn "OvirtProvisionPlugin:: Host #{ovirt_host_id} does not exists on ovirt"
        return nil
      end
      ovirt_host
    end

    def host_service(client)
      client.system_service.hosts_service.host_service(ovirt_host_id)
    end

    def status_installing?(host)
      return false if host.status.strip != "installing_os"

      logger.info "OvirtProvisionPlugin:: host in status '#{host.status}'"
      true
    end

    def ovirt_client
      cr_id = parameters.find_by(:name => "compute_resource_id").value
      cr = ComputeResource.find(cr_id)
      connection_opts = {
        :url      => cr.url,
        :username => cr.user,
        :password => cr.password
      }
      if cr.public_key.blank?
        connection_opts[:insecure] = true
      else
        connection_opts[:ca_certs] = [cr.public_key]
      end
      OvirtSDK4::Connection.new(connection_opts)
    rescue NoMethodError
      logger.error "OvirtProvisionPlugin:: fail to read compute_rescource_id on host #{name}, id #{cr_id}"
      nil
    rescue StandardError
      logger.error "OvirtProvisionPlugin:: error occured during ovirt_client #{e}"
      nil
    end

    def ovirt_host?
      host_id = ovirt_host_id
      return false if host_id.nil?

      logger.info "OvirtProvisionPlugin:: host #{host_id} is related to oVirt"
      true
    end

    def ovirt_host_id
      parameters.find_by(:name => "host_ovirt_id").value
    rescue StandardError
      logger.error "OvirtProvisionPlugin:: error occured during ovirt_host_id for #{name}"
      nil
    end

    def ovirt_node?
      return false unless ["oVirt-Node", "RHEV-H"].include?(operatingsystem.name)

      logger.info "OvirtProvisionPlugin:: Provisioned ovirt node host #{name}"
      true
    end
  end
end
