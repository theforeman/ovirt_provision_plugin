require File.expand_path('../lib/ovirt_provision_plugin/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "ovirt_provision_plugin"
  s.version     = OvirtProvisionPlugin::VERSION
  s.authors     = ["Yaniv Bronhaim"]
  s.email       = ["ybronhei@redhat.com"]
  s.homepage    = "https://github.com/theforeman/ovirt_provision_plugin"
  s.summary     = "This plugin monitors oVirt provision for new host and perform related API calls to ovirt-engine."
  s.description = "Ovirt provision plugin sends API request to oVirt management to reinstall host id after discovered hosts are first provisioned by oVirt engine (Using foreman provider integration)."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "ovirt-engine-sdk", ">= 4.1.3"
end
