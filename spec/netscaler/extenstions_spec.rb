require 'spec_helpers'
require 'netscaler/extensions'

describe Array do
  it "should just print out the [] when empty" do
    [].to_json.should eql('[]')
  end

  it "should indent the [] if given" do
    [].to_json('  ').should eql('  []')
  end

  class Integer
    def to_json(prefix=nil)
      to_s
    end
  end

  it "should print out the contents, one line each." do
    [1, 2, 3].to_json.should eql("[\n  1,\n  2,\n  3\n]\n")
  end

  it "should print out the contents indented" do
    [1, 2, 3].to_json('  ').should eql("  [\n    1,\n    2,\n    3\n  ]\n")
  end
end
