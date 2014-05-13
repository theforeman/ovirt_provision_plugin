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
            exec_cmd("echo 'I am here'")
            # call ovirt
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
	return true
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
