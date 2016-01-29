require 'minitest/autorun'
require 'minitest/pride'
require 'lens_of_truth'

using LensOfTruth

describe 'Object#find_nearby' do

  it "should be able to find an Enumerator's underlying Fiber" do
    require 'fiber'

    enum = Enumerator.new { |y| y << y.find_nearby(Fiber) << 42 }
    enum.next.transfer

    e = -> { enum.next }.must_raise FiberError
    e.message.must_match 'cannot resume transferred Fiber'
  end

  it "should be able to find a singleton class's attachee" do
    obj = Object.new
    cls = obj.singleton_class

    cls.find_nearby { |o|
      o.singleton_class == cls rescue nil
    }.must_be_same_as obj
  end

  # NOTE: These next two are kinda flaky.

  it "should be able to grab a lazy sequence's method" do
    seq = [].lazy

    foo = proc {} # Sprinkle the stack
    seq = seq.map &:succ
    bar = proc {} # for confusion.

    seq.find_nearby(Proc).call(41).must_equal 42
  end

  it "should be able to grab a lazy sequence's arguments" do
    seq = [].lazy

    foo = [1,2,3] # More
    seq = seq.take 10
    bar = [4,5,6] # sprinkles.

    seq.find_nearby(Array).must_equal [10]
  end
end
