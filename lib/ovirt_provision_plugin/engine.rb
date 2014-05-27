require 'deface'

module OvirtProvisionPlugin
  class Engine < ::Rails::Engine

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer "ovirt_provision_plugin.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += OvirtProvisionPlugin::Engine.paths['db/migrate'].existent
    end

    initializer 'ovirt_provision_plugin.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :ovirt_provision_plugin do
        requires_foreman '>= 1.4'

        # Add permissions
        security_block :ovirt_provision_plugin do
          permission :view_ovirt_provision_plugin, {:'ovirt_provision_plugin/hosts' => [:ovirt_hosts] }
        end

        # Add a new role called 'Discovery' if it doesn't exist
        role "OvirtProvisionPlugin", [:view_ovirt_provision_plugin]

        #add menu entry
        menu :top_menu, :template,
             :url_hash => {:controller => :'ovirt_provision_plugin/hosts', :action => :ovirt_hosts },
             :caption  => 'oVirt Hosts',
             :parent   => :hosts_menu,
             :after    => :hosts
      end
    end

    #Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        Host::Managed.send(:include, OvirtProvisionPlugin::HostExtensions)
        Report.send(:include, OvirtProvisionPlugin::ReportExtensions)
        HostsHelper.send(:include, OvirtProvisionPlugin::HostsHelperExtensions)
      rescue => e
        puts "OvirtProvisionPlugin: skipping engine hook (#{e.to_s})"
      end
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        OvirtProvisionPlugin::Engine.load_seed
      end
    end

  end
end
