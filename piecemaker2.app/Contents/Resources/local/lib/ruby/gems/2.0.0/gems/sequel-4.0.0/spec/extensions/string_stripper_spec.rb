require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe "Sequel::Plugins::StringStripper" do
  before do
    @db = Sequel.mock
    @c = Class.new(Sequel::Model(@db[:test]))
    @c.columns :name, :b
    @c.db_schema[:b][:type] = :blob
    @c.plugin :string_stripper
    @o = @c.new
  end

  it "should strip all input strings" do
    @o.name = ' name '
    @o.name.should == 'name'
  end

  it "should not affect other types" do
    @o.name = 1
    @o.name.should == 1
    @o.name = Date.today
    @o.name.should == Date.today
  end

  it "should not strip strings for blob arguments" do
    v = Sequel.blob(' name ')
    @o.name = v
    @o.name.should equal(v)
  end

  it "should not strip strings for blob columns" do
    @o.b = ' name '
    @o.b.should be_a_kind_of(Sequel::SQL::Blob)
    @o.b.should == Sequel.blob(' name ')
  end

  it "should allow skipping of columns using Model.skip_string_stripping" do
    @c.skip_string_stripping?(:name).should == false
    @c.skip_string_stripping :name
    @c.skip_string_stripping?(:name).should == true
    v = ' name '
    @o.name = v
    @o.name.should equal(v)
  end

  it "should work correctly in subclasses" do
    o = Class.new(@c).new
    o.name = ' name '
    o.name.should == 'name'
    o.b = ' name '
    o.b.should be_a_kind_of(Sequel::SQL::Blob)
    o.b.should == Sequel.blob(' name ')
  end

  it "should work correctly for dataset changes" do
    c = Class.new(Sequel::Model(@db[:test]))
    c.plugin :string_stripper
    def @db.supports_schema_parsing?() true end
    def @db.schema(*) [[:name, {}], [:b, {:type=>:blob}]] end
    c.set_dataset(@db[:test2])
    o = c.new
    o.name = ' name '
    o.name.should == 'name'
    o.b = ' name '
    o.b.should be_a_kind_of(Sequel::SQL::Blob)
    o.b.should == Sequel.blob(' name ')
  end
end
