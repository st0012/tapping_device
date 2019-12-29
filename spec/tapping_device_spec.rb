require "spec_helper"

RSpec.describe TappingDevice do
  it "supports multiple tappings" do
    stan = Student.new("Stan", 18)

    count_1 = 0
    count_2 = 0

    device_1 = described_class.new { count_1 += 1 }
    device_2 = described_class.new { count_2 -= 1 }

    device_1.tap_on!(stan)
    device_2.tap_on!(stan)

    stan.name

    expect(count_1).to eq(1)
    expect(count_2).to eq(-1)
  end
  describe "tap_passed!"do
    let(:device) { described_class.new }
    subject { :tap_passed! }

    def foo(obj)
      obj
    end

    def bar(obj)
      obj
    end

    private

    def private_foo(obj)
      obj
    end
    it "records all arguments usages of the object" do
      s = Student.new("Stan", 18)
      device.tap_passed!(s)

      foo(s); line_1 = __LINE__
      s.name
      bar(s); line_2 = __LINE__
      foo("123")

      expect(device.calls.count).to eq(2)

      call = device.calls.first
      expect(call.target).to eq(s)
      expect(call.method_name).to eq(:foo)
      expect(call.line_number).to eq(line_1.to_s)

      call = device.calls.second
      expect(call.target).to eq(s)
      expect(call.method_name).to eq(:bar)
      expect(call.line_number).to eq(line_2.to_s)
    end
    it "records private calls as well" do
      s = Student.new("Stan", 18)
      device.tap_passed!(s)

      send(:private_foo, s); line_1 = __LINE__

      expect(device.calls.count).to eq(1)

      call = device.calls.first
      expect(call.method_name).to eq(:private_foo)
      expect(call.line_number).to eq(line_1.to_s)
    end
    it "works even if the object's `method` method has been overriden" do
      class Baz
        def method

        end

        def foo(obj)
          obj
        end
      end

      s = Student.new("Stan", 18)
      device.tap_passed!(s)

      Baz.new.foo(s); line_1 = __LINE__

      expect(device.calls.count).to eq(1)

      call = device.calls.first
      expect(call.method_name).to eq(:foo)
      expect(call.line_number).to eq(line_1.to_s)
    end
    it "works even if the object's `method` method has been overriden (2)" do
      class Baz
        def method

        end

        private

        def foo(obj)
          obj
        end
      end

      s = Student.new("Stan", 18)
      device.tap_passed!(s)

      Baz.new.send(:foo, s); line_1 = __LINE__

      expect(device.calls.count).to eq(1)

      call = device.calls.first
      expect(call.method_name).to eq(:foo)
      expect(call.line_number).to eq(line_1.to_s)
    end
  end
  describe "#tap_init!" do
    let(:device) { described_class.new }
    subject { :tap_init! }

    it "tracks Student's initialization" do
      device.tap_init!(Student)

      Student.new("Stan", 18)
      Student.new("Jane", 23)

      expect(device.calls.count).to eq(2)
    end
    it "can track subclass's initialization as well" do
      device.tap_init!(HighSchoolStudent)

      HighSchoolStudent.new("Stan", 18)

      expect(device.calls.count).to eq(1)
      expect(device.calls.first.target).to eq(HighSchoolStudent)
    end
    it "doesn't track School's initialization" do
      device.tap_init!(Student)

      School.new("A school")

      expect(device.calls.count).to eq(0)
    end
    it "doesn't track non-initialization method calls" do
      device.tap_init!(Student)

      Student.foo

      expect(device.calls.count).to eq(0)
    end

    it_behaves_like "stoppable" do
      let(:target) { Student }
      let(:trigger_action) do
        -> (target) { target.new("Stan", 18) }
      end
    end
  end
  describe "#and_print" do
    let(:device) { described_class.new }

    it "outputs payload with given payload method" do
      stan = Student.new("Stan", 18)
      device.tap_on!(stan).and_print(:method_name_and_arguments)

      expect do
        stan.name
      end.to output("name <= {}\n").to_stdout
    end
  end

  describe ".devices" do
    it "stores all initialized devices" do
      device_1 = described_class.new
      device_2 = described_class.new
      device_3 = described_class.new

      device_2.stop!

      expect(described_class.devices).to match_array([device_1, device_3])

      described_class.stop_all!

      expect(described_class.devices).to match_array([])
    end
  end

  describe ".suspend_new!" do
    it "stops all devices and won't enable new ones" do
      described_class.suspend_new!

      device_1 = described_class.new
      device_1.tap_init!(Student)

      Student.new("stan", 0)

      expect(device_1.calls.count).to eq(0)
    end
  end
end
