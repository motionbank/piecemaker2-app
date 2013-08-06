require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe "Sequel::Plugins::DefaultsSetter" do
  before do
    @db = db = Sequel.mock
    def db.supports_schema_parsing?() true end
    @c = c = Class.new(Sequel::Model(db[:foo]))
    @c.instance_variable_set(:@db_schema, {:a=>{}})
    @c.plugin :defaults_setter
    @c.columns :a
    @pr = proc{|x| db.meta_def(:schema){|*| [[:a, {:ruby_default => x}]]}; c.dataset = c.dataset; c}
  end
  after do
    Sequel.datetime_class = Time
  end

  it "should set default value upon initialization" do
    @pr.call(2).new.a.should == 2
  end

  it "should not mark the column as modified" do
    @pr.call(2).new.changed_columns.should == []
  end

  it "should not set a default of nil" do
    @pr.call(nil).new.class.default_values.should == {}
  end

  it "should set a default of false" do
    @pr.call(false).new.a.should == false
  end

  it "should handle Sequel::CURRENT_DATE default by using the current Date" do
    @pr.call(Sequel::CURRENT_DATE).new.a.should == Date.today
  end

  it "should handle Sequel::CURRENT_TIMESTAMP default by using the current Time" do
    t = @pr.call(Sequel::CURRENT_TIMESTAMP).new.a
    t.should be_a_kind_of(Time)
    (t - Time.now).should < 1
  end

  it "should handle Sequel::CURRENT_TIMESTAMP default by using the current DateTime if Sequel.datetime_class is DateTime" do
    Sequel.datetime_class = DateTime
    t = @pr.call(Sequel::CURRENT_TIMESTAMP).new.a
    t.should be_a_kind_of(DateTime)
    (t - DateTime.now).should < 1/86400.0
  end

  it "should not override a given value" do
    @pr.call(2)
    @c.new('a'=>3).a.should == 3
    @c.new('a'=>nil).a.should == nil
  end

  it "should work correctly when subclassing" do
    Class.new(@pr.call(2)).new.a.should == 2
  end

  it "should contain the default values in default_values" do
    @pr.call(2).default_values.should == {:a=>2}
    @pr.call(nil).default_values.should == {}
  end

  it "should allow modifications of default values" do
    @pr.call(2)
    @c.default_values[:a] = 3
    @c.new.a.should == 3
  end

  it "should allow proc default values" do
    @pr.call(2)
    @c.default_values[:a] = proc{3}
    @c.new.a.should == 3
  end

  it "should have procs that set default values set them to nil" do
    @pr.call(2)
    @c.default_values[:a] = proc{nil}
    @c.new.a.should == nil
  end

  it "should work correctly on a model without a dataset" do
    @pr.call(2)
    c = Class.new(Sequel::Model(@db[:bar]))
    c.plugin :defaults_setter
    c.default_values.should == {:a=>2}
  end
end
