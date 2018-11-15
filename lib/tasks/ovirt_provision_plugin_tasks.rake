# Tasks
namespace :ovirt_provision_plugin do
  namespace :example do
    desc 'Example Task'
    task :task => :environment do
      # Task goes here
    end
  end
end

# Tests
namespace :test do
  desc "Test OvirtProvisionPlugin"
  Rake::TestTask.new(:ovirt_provision_plugin) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ["test", test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:ovirt_provision_plugin'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:setup')
  Rake::Task["jenkins:unit"].enhance do
    Rake::Task['test:ovirt_provision_plugin'].invoke
  end
end
