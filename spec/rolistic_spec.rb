require "spec_helper"

describe Rolistic do
  it "has a version number" do
    expect(Rolistic::VERSION).not_to be nil
  end

  it "is a module" do
    expect(subject.class).to eq(Module)
  end
end
