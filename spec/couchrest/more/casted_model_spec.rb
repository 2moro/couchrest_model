require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(FIXTURE_PATH, 'more', 'card')

class WithCastedModelMixin < Hash
  include CouchRest::CastedModel
  property :name
end

class DummyModel < CouchRest::ExtendedDocument
  use_database TEST_SERVER.default_database
  raise "Default DB not set" if TEST_SERVER.default_database.nil?
  property :casted_attribute, :cast_as => 'WithCastedModelMixin'
end


describe CouchRest::CastedModel do
  
  describe "A non hash class including CastedModel" do
    it "should fail raising and include error" do
      lambda do
        class NotAHashButWithCastedModelMixin
          include CouchRest::CastedModel
          property :name
        end
        
      end.should raise_error
    end
  end
  
  describe "isolated" do
    before(:each) do
      @obj = WithCastedModelMixin.new
    end
    it "should automatically include the property mixin and define getters and setters" do
      @obj.name = 'Matt'
      @obj.name.should == 'Matt' 
    end
  end
  
  describe "casted as attribute" do
    before(:each) do
      @obj = DummyModel.new(:casted_attribute => {:name => 'whatever'})
      @casted_obj = @obj.casted_attribute
    end
    
    it "should be available from its parent" do
      @casted_obj.should be_an_instance_of(WithCastedModelMixin)
    end
    
    it "should have the getters defined" do
      @casted_obj.name.should == 'whatever'
    end
    
    it "should know who casted it" do
      @casted_obj.casted_by.should == @obj
    end
  end
  
  describe "saved document with casted models" do
    before(:each) do
      @obj = DummyModel.new(:casted_attribute => {:name => 'whatever'})
      @obj.save
    end
    
    it "should be able to load with the casted models" do
      casted_obj = @obj.casted_attribute
      casted_obj.should_not be_nil
      casted_obj.should be_an_instance_of(WithCastedModelMixin)
    end
    
    it "should have defined getters for the casted model" do
      casted_obj = @obj.casted_attribute
      casted_obj.name.should == "whatever"
    end
    
    it "should have defined setters for the casted model" do
      casted_obj = @obj.casted_attribute
      casted_obj.name = "test"
      casted_obj.name.should == "test"
    end
    
  end
  
end