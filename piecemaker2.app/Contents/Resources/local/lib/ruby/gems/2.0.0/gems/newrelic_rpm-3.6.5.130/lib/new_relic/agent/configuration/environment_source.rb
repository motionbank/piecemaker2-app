# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

module NewRelic
  module Agent
    module Configuration
      class EnvironmentSource < DottedHash
        def initialize
          string_map = {
            'NRCONFIG'              => :config_path,
            'NEW_RELIC_LICENSE_KEY' => :license_key,
            'NEWRELIC_LICENSE_KEY'  => :license_key,
            'NEW_RELIC_APP_NAME'    => :app_name,
            'NEWRELIC_APP_NAME'     => :app_name,
            'NEW_RELIC_HOST'        => :host,
            'NEW_RELIC_PORT'        => :port
          }.each do |key, val|
            self[val] = ENV[key] if ENV[key]
          end

          symbol_map = {
            'NEW_RELIC_DISPATCHER'  => :dispatcher,
            'NEWRELIC_DISPATCHER'   => :dispatcher,
            'NEW_RELIC_FRAMEWORK'   => :framework,
            'NEWRELIC_FRAMEWORK'    => :framework
          }.each do |key, val|
            self[val] = ENV[key].intern if ENV[key]
          end

          boolean_map = {
            'NEWRELIC_ENABLE' => :agent_enabled,
            'NEWRELIC_ENABLED' => :agent_enabled,
            'NEW_RELIC_ENABLE' => :agent_enabled,
            'NEW_RELIC_ENABLED' => :agent_enabled
          }.each do |key, val|
            if ENV[key].to_s =~ /false|off|no/i
              self[val] = false
            elsif ENV[key] != nil
              self[val] = true
            end
          end

          if ENV['NEW_RELIC_LOG']
            if ENV['NEW_RELIC_LOG'].upcase == 'STDOUT'
              self[:log_file_path] = self[:log_file_name] = 'STDOUT'
            else
              self[:log_file_path] = File.dirname(ENV['NEW_RELIC_LOG'])
              self[:log_file_name] = File.basename(ENV['NEW_RELIC_LOG'])
            end
          end
        end
      end
    end
  end
end
