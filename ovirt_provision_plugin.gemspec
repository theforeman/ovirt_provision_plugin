require File.expand_path('../lib/ovirt_provision_plugin/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "ovirt_provision_plugin"
  s.version     = OvirtProvisionPlugin::VERSION
  s.date        = Date.today.to_s
  s.authors     = ["Yaniv Bronhaim"]
  s.email       = ["ybronhei@redhat.com"]
  s.homepage    = ""
  s.summary     = "This plugin monitors oVirt provision for new host and perform related API calls to ovirt-engine."
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "deface"
  #s.add_development_dependency "sqlite3"
end
