require 'fastlane/plugin/appload/version'

module Fastlane
  module Appload
    # Return all .rb files inside the "actions" directory
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

# By default we want to import all available actions
# A plugin can contain any number of actions and plugins
Fastlane::Appload.all_classes.each do |current|
  require current
end
