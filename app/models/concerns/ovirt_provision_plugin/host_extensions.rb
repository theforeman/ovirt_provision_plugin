module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      after_save :engine_callback
    end

    def engine_callback
        if host_ready? && provisioned_recently? && ovirt_host?
            cr = ComputeResource.find_by_name('ovirt-engine')
            host_id = parameters.find_by_name("host_ovirt_id").value
            logger.debug "OvirtProvisionPlugin:: Host #{host_id} as been provisioned. Sending approve request to #{cr.url}"
            client = OVIRT::Client.new('#{cr.user}', '#{cr.password}', '#{cr.url}')

            # approve uses pk
            client.approve_host("#{host_id}")
        end
    end

    def host_ready?
        fail(Foreman::Exception, "Latest Puppet Run Contains Failures for Host: #{id}") if failed > 0
        skipped == 0 && pending == 0
    end

    def provisioned_recently?
        last_report_was.blank? && last_report.blank?
    end

    def ovirt_host?
        return (not parameters.find_by_name("host_ovirt_id").blank?)
    end
  end
end
