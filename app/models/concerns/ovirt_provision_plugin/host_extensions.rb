module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      # execute callbacks
      after_update :engine_callback
    end

    # create or overwrite instance methods...
    def engine_callback
        if host_ready? && provisioned_recently? && ovirt_host?
            # call ovirt
        end
    end

    def host_ready?
        fail(Foreman::Exception, "Latest Puppet Run Contains Failures for Host: #{id}") if host.failed > 0
        host.skipped == 0 && host.pending == 0
    end
    
    def provisioned_recently?
        old.last_repost = nil && last_report != nil
    end

    def ovirt_host?
	# ?
    end
  end
end
