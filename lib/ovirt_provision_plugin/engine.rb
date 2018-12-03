module OvirtProvisionPlugin
  class Engine < ::Rails::Engine
    engine_name "ovirt_provision_plugin"

    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    initializer 'ovirt_provision_plugin.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :ovirt_provision_plugin do
        requires_foreman ">= 1.4"
      end
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        Host::Managed.send(:include, OvirtProvisionPlugin::HostExtensions)
        Report.send(:include, OvirtProvisionPlugin::ReportExtensions)
      rescue StandardError => e
        Rails.logger.warn "OvirtProvisionPlugin: skipping engine hook (#{e})"
      end
    end

    initializer "ovirt_provision_plugin.register_gettext", after: :load_config_initializers do
      locale_dir = File.join(File.expand_path("../..", __dir__), "locale")
      locale_domain = "ovirt_provision_plugin"
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
