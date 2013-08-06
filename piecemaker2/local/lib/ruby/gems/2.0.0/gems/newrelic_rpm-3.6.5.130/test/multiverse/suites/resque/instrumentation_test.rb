# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

# https://newrelic.atlassian.net/browse/RUBY-669

require 'resque'
require 'test/unit'
require 'logger'
require 'newrelic_rpm'
require 'fake_collector'

class ResqueTest < Test::Unit::TestCase
  class JobForTesting
    @queue = :resque_test
    @count = 0

    def self.reset_counter
      @count = 0
    end

    def self.count
      @count
    end

    def self.perform(sleep_duration=0)
      sleep sleep_duration
      @count += 1
    end
  end

  JOB_COUNT = 5

  def setup
    $collector ||= NewRelic::FakeCollector.new
    $collector.reset
    $collector.run

    JobForTesting.reset_counter

    # From multiverse, we only run the Resque jobs inline to check that we
    # are properly instrumenting the methods. Testing of the forking/backgrounding
    # will be done in our upcoming end-to-end testing suites
    Resque.inline = true

    JOB_COUNT.times do |i|
      Resque.enqueue(JobForTesting)
    end

    NewRelic::Agent.instance.send(:transmit_data)
  end

  def test_all_jobs_ran
    assert_equal(JOB_COUNT, JobForTesting.count)
  end

  def test_agent_posts_correct_metric_data
    assert_metric_and_call_count('Instance/Busy', 1)
    assert_metric_and_call_count('OtherTransaction/ResqueJob/all', JOB_COUNT)
  end

  def test_agent_still_running_after_inline_job
    assert NewRelic::Agent.instance.started?
  end

  METRIC_VALUES_POSITION = 3

  def assert_metric_and_call_count(name, expected_call_count)
    metric_data = $collector.calls_for('metric_data')
    assert_equal(1, metric_data.size, "expected exactly one metric_data post from agent")

    metric = metric_data.first[METRIC_VALUES_POSITION].find { |m| m[0]['name'] == name }
    assert(metric, "could not find metric named #{name}")

    call_count = metric[1][0]
    assert_equal(expected_call_count, call_count)
  end
end
