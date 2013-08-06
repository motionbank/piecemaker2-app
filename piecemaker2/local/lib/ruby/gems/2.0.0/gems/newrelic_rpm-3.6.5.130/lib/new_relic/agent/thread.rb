# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

module NewRelic
  module Agent

    class AgentThread < ::Thread
      def initialize(label)
        ::NewRelic::Agent.logger.debug("Creating New Relic thread: #{label}")
        self[:newrelic_label] = label
        super
      end

      def self.bucket_thread(thread, profile_agent_code)
        if thread.key?(:newrelic_label)
          return profile_agent_code ? :agent : :ignore
        elsif thread[:newrelic_transaction].respond_to?(:last) &&
            thread[:newrelic_transaction].last
          thread[:newrelic_transaction].last.request.nil? ? :background : :request
        else
          :other
        end
      end

      def self.scrub_backtrace(thread, profile_agent_code)
        begin
          bt = thread.backtrace
        rescue Exception => e
          ::NewRelic::Agent.logger.debug("Failed to backtrace #{thread.inspect}: #{e.class.name}: #{e.to_s}")
        end
        return nil unless bt
        profile_agent_code ? bt : bt.select { |t| t !~ /\/newrelic_rpm-\d/ }
      end
    end
  end
end
