require File.expand_path('../../spec_helper', __FILE__)

describe 'DataStruct' do
  before do
    @s1 = Class.new(MonitoringProtocols::DataStruct) do
      properties :one, :two
    end
    
    @s2 = Class.new(MonitoringProtocols::DataStruct) do
      properties :name, :host
    end
  end
  
  it 'can be encoded with msgpack', focus: true do
    obj = @s1.new(:one => 12)
    data = MessagePack.pack(obj)
    h = MessagePack.unpack(data)
    h.class.should == Hash
    h['one'].should == 12
    h['two'].should == nil
  end
  
  should 'raise an error if keys are unknown' do
    err = ->{
      @s1.new(tarzan: 42)
    }.should.raise(ArgumentError)
    
    err.message.should.include?("tarzan")
  end
  
  should 'have disctinct attributes set for each child class' do
    @s1.attributes.should == [:one, :two]
    @s2.attributes.should == [:name, :host]
  end
  
  it "can merge data from multiple Hash sources" do
    obj = @s1.new(:one => 12)
    obj.merge_data_from!(:two => 34, :one => nil)
    
    obj.one.should == 12
    obj.two.should == 34
  end
  
  it "can merge data from multiple Object sources" do
    dummy_class = Struct.new(:one, :two)
    
    d1 = dummy_class.new(23)
    d2 = dummy_class.new(nil, 56)
    
    obj = @s1.new(d1)
    obj.merge_data_from!(d2)
    
    obj.one.should == 23
    obj.two.should == 56
  end
  
  it "can merge data selectively from multiple Object sources" do
    dummy_class = Struct.new(:one, :two)
    
    d1 = dummy_class.new(23)
    d2 = dummy_class.new(67, 56)
    
    obj = @s1.new(d1)
    obj.merge_data_from!(d2, [:two])
    
    obj.one.should == 23
    obj.two.should == 56
  end
  
  should 'support inheritance' do
    c1 = Class.new(MonitoringProtocols::DataStruct) do
      properties :one, :two
    end
    
    c2 = Class.new(c1) do
      properties :three
    end
    
    
    obj = c2.new(one: 1, two: 2, three: 3)
    c2.attributes.should == [:one, :two, :three]
    
    obj.one.should == 1
    obj.two.should == 2
    obj.three.should == 3
  end
  
end

