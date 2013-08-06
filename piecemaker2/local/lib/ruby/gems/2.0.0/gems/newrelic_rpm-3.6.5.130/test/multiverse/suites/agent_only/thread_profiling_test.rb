# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

# https://newrelic.atlassian.net/wiki/display/eng/Agent+Thread+Profiling
# https://newrelic.atlassian.net/browse/RUBY-917

if RUBY_VERSION >= '1.9'
class ThreadProfilingTest < Test::Unit::TestCase
  def setup
    $collector ||= NewRelic::FakeCollector.new
    $collector.reset
    $collector.mock['connect'] = [200, {'return_value' => {"agent_run_id" => 666 }}]
    $collector.mock['get_agent_commands'] = [200, {'return_value' => START_COMMAND}]
    $collector.mock['agent_command_results'] = [200, {'return_value' => []}]
    $collector.run

    NewRelic::Agent::Agent.instance_variable_set(:@instance, nil)
    NewRelic::Agent.manual_start(:'thread_profiler.enabled' => true, :force_send => true)
    NewRelic::Agent.instance.service.request_timeout = 0.5
    NewRelic::Agent.instance.service.agent_id = 666

    @agent = NewRelic::Agent.instance
    @thread_profiler = @agent.thread_profiler
    @threads = []
  end

  def teardown
    $collector.reset

    @threads.each { |t| t.kill }
    @threads = nil
  end

  START_COMMAND = [[666,{
      "name" => "start_profiler",
      "arguments" => {
        "profile_id" => -1,
        "sample_period" => 0.01,
        "duration" => 0.5,
        "only_runnable_threads" => false,
        "only_request_threads" => false,
        "profile_agent_code" => true
      }
    }]]

  STOP_COMMAND = [[666,{
      "name" => "stop_profiler",
      "arguments" => {
        "profile_id" => -1,
        "report_data" => true
      }
    }]]

  # These are potentially fragile for being timing based
  # START_COMMAND with 0.01 sampling and 0.5 duration expects to get
  # roughly 50 polling cycles in. We check signficiantly less than that.

  # STOP_COMMAND when immediately issued after a START_COMMAND is expected
  # go only let a few cycles through, so we check less than 10

  def test_thread_profiling
    @agent.send(:check_for_agent_commands)

    run_thread { NewRelic::Agent::Transaction.start(:controller, :request => stub) }
    run_thread { NewRelic::Agent::Transaction.start(:task) }

    let_it_finish

    profile_data = $collector.calls_for('profile_data')[0]
    assert_equal('666', profile_data.run_id, "Missing run_id, profile_data was #{profile_data.inspect}")
    assert(profile_data.poll_count > 10, "Expected poll_count > 10, but was #{profile_data.poll_count}")

    assert_saw_traces(profile_data, "OTHER")
    assert_saw_traces(profile_data, "AGENT")
    assert_saw_traces(profile_data, "REQUEST")
    assert_saw_traces(profile_data, "BACKGROUND")
  end

  def test_thread_profiling_can_stop
    @agent.send(:check_for_agent_commands)

    $collector.mock['get_agent_commands'] = [200, {'return_value' => STOP_COMMAND}]
    @agent.send(:check_for_agent_commands)

    let_it_finish

    profile_data = $collector.calls_for('profile_data')[0]
    assert_equal('666', profile_data.run_id, "Missing run_id, profile_data was #{profile_data.inspect}")
    assert(profile_data.poll_count < 50, "Expected poll_count < 50, but was #{profile_data.poll_count}")
  end

  # Runs a thread we expect to span entire test and be killed at the end
  def run_thread
    Thread.new do
      yield
      sleep(10)
    end
  end

  def let_it_finish
    Timeout.timeout(5) do
      until @thread_profiler.finished?
        sleep(0.1)
      end
    end

    @agent.send(:transmit_data, true)
  end

  def assert_saw_traces(profile_data, type)
    assert !profile_data.traces[type].empty?, "Missing #{type} traces"
  end

end
end

