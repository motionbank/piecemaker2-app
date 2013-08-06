# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

if defined?(::Rails) && ::Rails::VERSION::MAJOR.to_i >= 4 && !NewRelic::LanguageSupport.using_engine?('jruby')

require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','test_helper'))
require 'new_relic/agent/instrumentation/active_record_subscriber'

class NewRelic::Agent::Instrumentation::ActiveRecordSubscriberTest < Test::Unit::TestCase
  class Order; end

  def setup
    @config = { :adapter => 'mysql', :host => 'server' }
    @connection = Object.new
    @connection.instance_variable_set(:@config, @config)
    Order.stubs(:connection_pool).returns(stub(:connections => [ @connection ]))

    @params = {
      :name => 'NewRelic::Agent::Instrumentation::ActiveRecordSubscriberTest::Order Load',
      :sql => 'SELECT * FROM sandwiches',
      :connection_id => @connection.object_id
    }

    @subscriber = NewRelic::Agent::Instrumentation::ActiveRecordSubscriber.new

    @stats_engine = NewRelic::Agent.instance.stats_engine
    @stats_engine.clear_stats
  end

  def test_records_metrics_for_simple_find
    t1 = Time.now
    t0 = t1 - 2
    @subscriber.call('sql.active_record', t0, t1, :id, @params)

    metric_name = 'ActiveRecord/NewRelic::Agent::Instrumentation::ActiveRecordSubscriberTest::Order/find'

    metric = @stats_engine.lookup_stats(metric_name)
    assert_equal(1, metric.call_count)
    assert_equal(2.0, metric.total_call_time)
  end

  def test_records_scoped_metrics
    t1 = Time.now
    t0 = t1 - 2

    in_transaction('test_txn') do
      @subscriber.call('sql.active_record', t0, t1, :id, @params)
    end

    metric_name = 'ActiveRecord/NewRelic::Agent::Instrumentation::ActiveRecordSubscriberTest::Order/find'
    assert_metrics_recorded(
      [metric_name, 'test_txn'] => { :call_count => 1, :total_call_time => 2 }
    )
  end

  def test_records_nothing_if_tracing_disabled
    t1 = Time.now
    t0 = t1 - 2

    NewRelic::Agent.disable_all_tracing do
      @subscriber.call('sql.active_record', t0, t1, :id, @params)
    end

    metric_name = 'ActiveRecord/NewRelic::Agent::Instrumentation::ActiveRecordSubscriberTest::Order/find'
    assert_metrics_not_recorded([metric_name])
  end

  def test_records_rollup_metrics
    t1 = Time.now
    t0 = t1 - 2

    in_web_transaction do
      @subscriber.call('sql.active_record', t0, t1, :id, @params)
    end

    assert_metrics_recorded(
      'ActiveRecord/find' => { :call_count => 1, :total_call_time => 2 },
      'ActiveRecord/all' => { :call_count => 1, :total_call_time => 2 }
    )
  end

  def test_records_remote_service_metric
    t1 = Time.now
    t0 = t1 - 2

    @subscriber.call('sql.active_record', t0, t1, :id, @params)

    assert_metrics_recorded(
      'RemoteService/sql/mysql/server' => { :call_count => 1, :total_call_time => 2.0 }
    )
  end

  def test_creates_txn_segment
    t1 = Time.now
    t0 = t1 - 2

    NewRelic::Agent.manual_start
    @stats_engine.start_transaction
    sampler = NewRelic::Agent.instance.transaction_sampler
    sampler.notice_first_scope_push(Time.now.to_f)
    sampler.notice_transaction('/path', {})
    sampler.notice_push_scope('Controller/sandwiches/index')
    @subscriber.call('sql.active_record', t0, t1, :id, @params)
    sampler.notice_pop_scope('Controller/sandwiches/index')
    sampler.notice_scope_empty(stub('txn', :name => '/path', :custom_parameters => {}))

    last_segment = nil
    sampler.last_sample.root_segment.each_segment{|s| last_segment = s }
    NewRelic::Agent.shutdown

    assert_equal('ActiveRecord/NewRelic::Agent::Instrumentation::ActiveRecordSubscriberTest::Order/find',
                 last_segment.metric_name)
    assert_equal('SELECT * FROM sandwiches',
                 last_segment.params[:sql])
  end

  def test_creates_slow_sql_node
    NewRelic::Agent.manual_start
    sampler = NewRelic::Agent.instance.sql_sampler
    sampler.notice_first_scope_push nil
    t1 = Time.now
    t0 = t1 - 2

    @subscriber.call('sql.active_record', t0, t1, :id, @params)

    assert_equal 'SELECT * FROM sandwiches', sampler.transaction_data.sql_data[0].sql
  ensure
    NewRelic::Agent.shutdown
  end
end

else
  puts "Skipping tests in #{__FILE__} because Rails is unavailable"
end
