require 'open3'

module OvirtProvisionPlugin
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      # execute callbacks
      after_save :engine_callback
    end

    # create or overwrite instance methods...
    def engine_callback
        logger.debug "hey im on engine_callback"
        if host_ready? && provisioned_recently? && ovirt_host?
            # get ovirt user and password
            cr = ComputeResource.find_by_name('ovirt-engine')
            login = "#{cr.user}:#{cr.password}"
            host_id = parameters.find_by_name("host_ovirt_id").value
            exec_cmd("curl -X POST -H 'Content-type: application/xml' -u #{login} #{cr.url}/hosts/#{host_id}/approve -d <action></action>'")
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
        # how would i know that? parameter?
	      return parameters.find_by_name("host_ovirt_id").blank?
    end

    def exec_cmd(cmd)
        stdin, stdout, stderr = Open3.popen3(cmd)
        out=stdout.gets
        err=stdout.gets
        raise "ForemanPluginExecCmd: Could not execute command #{cmd}. Error: #{err}, Output: #{out}" unless $?.to_i == 0    
        [ out, err ]
    end

  end
end
