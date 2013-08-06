# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

module NewRelic
  module Agent
    module Configuration
      MASK_DEFAULTS = {
        :'thread_profiler' =>         Proc.new { !NewRelic::Agent::ThreadProfiler.is_supported? },
        :'thread_profiler.enabled' => Proc.new { !NewRelic::Agent::ThreadProfiler.is_supported? },
        :verify_certificate =>  Proc.new{ true }
      }
    end
  end
end
