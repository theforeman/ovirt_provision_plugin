require 'factory_bot_rails'

# This calls the main test_helper in Foreman-core
# require 'test_helper'

# Add plugin to FactoryGirl's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload
