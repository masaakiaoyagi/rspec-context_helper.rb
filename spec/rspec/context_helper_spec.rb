# frozen_string_literal: true

RSpec.configure do |config|
  # It's supposed to be the default option in RSpec 4.
  # https://github.com/rspec/rspec-core/issues/2832
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec::Matchers.define :have_metadata do |expected|
  match do |example|
    return false unless example.metadata.has_key?(expected)
    return true unless @check_expected_value
    example.metadata[expected] == @expected_value
  end

  chain :with do |expected_value|
    @check_expected_value = true
    @expected_value = expected_value
  end
end

RSpec.describe RSpec::ContextHelper do
  let(:description) { self.class.description }

  shared_context :s1 do |value = 1|
    let(:v1) { value }
  end

  shared_context :s2 do |value = 2|
    let(:v2) { value }
  end

  describe ".example_with" do
    example_with            {}
    example_with("message") {}
    example_with(a: "1")    { expect(a).to eq "1" }

    example_with "message", a: -> { b }, b: "2", c: -> { -> {} } do
      expect(a).to eq "2"
      expect(b).to eq "2"
      expect(c).to be_an_instance_of Proc
    end

    describe "description" do
      example_with                                           { expect(description).to eq "" }
      example_with("message")                                { expect(description).to eq "message" }
      example_with(_meta: :m1)                               { expect(description).to eq "" }
      example_with(_shared: :s1)                             { expect(description).to eq "when s1" }
      example_with(a: "1")                                   { expect(description).to eq %(when a is "1") }
      example_with(a: "1", b: "2")                           { expect(description).to eq %(when a is "1" and b is "2") }
      example_with(_meta: :m1, _shared: :s1, a: "1", b: "2") { expect(description).to eq %(when s1, a is "1" and b is "2") }
    end

    describe "metadata" do
      example_with(_meta: :m1)          { |e| expect(e).to have_metadata(:m1).with(true) }
      example_with(_meta: :m1)          { |e| expect(e).not_to have_metadata(:m2) }
      example_with(_meta: [:m1, :m2])   { |e| expect(e).to have_metadata(:m1).with(true) }
      example_with(_meta: [:m1, :m2])   { |e| expect(e).to have_metadata(:m2).with(true) }
      example_with(_meta: [:m1, m2: 3]) { |e| expect(e).to have_metadata(:m1).with(true) }
      example_with(_meta: [:m1, m2: 3]) { |e| expect(e).to have_metadata(:m2).with(3) }
    end

    describe "shared context" do
      example_with(_shared: :s1)          { expect(v1).to eq 1 }
      example_with(_shared: :s1)          { expect{ v2 }.to raise_error NameError }
      example_with(_shared: [:s1, :s2])   { expect(v1).to eq 1 }
      example_with(_shared: [:s1, :s2])   { expect(v2).to eq 2 }
      example_with(_shared: [:s1, s2: 3]) { expect(v1).to eq 1 }
      example_with(_shared: [:s1, s2: 3]) { expect(v2).to eq 3 }
    end
  end

  describe ".context_with" do
    context_with do
      example {}
    end

    context_with "message" do
      example {}
    end

    context_with a: "1" do
      example { expect(a).to eq "1" }
    end

    context_with "message", a: -> { b }, b: "2", c: -> { -> {} } do
      example { expect(a).to eq "2" }
      example { expect(b).to eq "2" }
      example { expect(c).to be_an_instance_of Proc }
    end

    describe "description" do
      context_with do
        example { expect(description).to eq "" }
      end

      context_with "message" do
        example { expect(description).to eq "message" }
      end

      context_with _meta: :m1 do
        example { expect(description).to eq "" }
      end

      context_with _shared: :s1 do
        example { expect(description).to eq "when s1" }
      end

      context_with a: "1" do
        example { expect(description).to eq %(when a is "1") }
      end

      context_with a: "1", b: "2" do
        example { expect(description).to eq %(when a is "1" and b is "2") }
      end

      context_with _meta: :m1, _shared: :s1, a: "1", b: "2" do
        example { expect(description).to eq %(when s1, a is "1" and b is "2") }
      end
    end

    describe "metadata" do
      context_with _meta: :m1 do
        example { |e| expect(e).to have_metadata(:m1).with(true) }
        example { |e| expect(e).not_to have_metadata(:m2) }
      end

      context_with _meta: [:m1, :m2] do
        example { |e| expect(e).to have_metadata(:m1).with(true) }
        example { |e| expect(e).to have_metadata(:m2).with(true) }
      end

      context_with _meta: [:m1, m2: 3] do
        example { |e| expect(e).to have_metadata(:m1).with(true) }
        example { |e| expect(e).to have_metadata(:m2).with(3) }
      end
    end

    describe "shared context" do
      context_with _shared: :s1 do
        example { expect(v1).to eq 1 }
        example { expect{ v2 }.to raise_error NameError }
      end

      context_with _shared: [:s1, :s2] do
        example { expect(v1).to eq 1 }
        example { expect(v2).to eq 2 }
      end

      context_with _shared: [:s1, s2: 3] do
        example { expect(v1).to eq 1 }
        example { expect(v2).to eq 3 }
      end
    end
  end
end
