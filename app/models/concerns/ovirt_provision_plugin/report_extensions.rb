module OvirtProvisionPlugin
  module ReportExtensions
    extend ActiveSupport::Concern

    included do
      after_commit :new_report_callback, :on => :create
    end

    def new_report_callback
      host.ovirt_host_callback if host.reports.count == 2
    end
  end
end
