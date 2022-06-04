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

RSpec::Matchers.define :have_included do |expected_name|
  match do |example|
    example.included_contexts.any? do |actual_name, actual_args, actual_opts|
      next false unless actual_name == expected_name
      break true unless @check_expected_args
      next false unless actual_args == @expected_args
      next false unless actual_opts == @expected_opts
      true
    end
  end

  chain :with do |*args|
    @check_expected_args = true
    @expected_args, @expected_opts = args.last.is_a?(::Hash) ? [args, args.pop] : [args, {}]
  end
end

RSpec.describe RSpec::ContextHelper do
  let(:description) { self.class.description }

  # for have_included matcher
  let(:included_contexts) { [] }
  shared_context :s1 do |*args, **opts|
    before { included_contexts << [:s1, args, opts] }
  end
  shared_context :s2 do |*args, **opts|
    before { included_contexts << [:s2, args, opts] }
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
      example_with(_meta: { m1: "3" })  { |e| expect(e).to have_metadata(:m1).with("3") }
      example_with(_meta: [:m1, m2: 3]) { |e| expect(e).to have_metadata(:m1).with(true) }
      example_with(_meta: [:m1, m2: 3]) { |e| expect(e).to have_metadata(:m2).with(3) }
    end

    describe "shared context" do
      example_with(_shared: :s1)                  { expect(self).to have_included(:s1).with }
      example_with(_shared: :s1)                  { expect(self).not_to have_included(:s2) }
      example_with(_shared: [:s1, :s2])           { expect(self).to have_included(:s1).with }
      example_with(_shared: [:s1, :s2])           { expect(self).to have_included(:s2).with }
      example_with(_shared: { s1: "3" })          { expect(self).to have_included(:s1).with("3") }
      example_with(_shared: [:s1, s2: 3])         { expect(self).to have_included(:s1).with }
      example_with(_shared: [:s1, s2: 3])         { expect(self).to have_included(:s2).with(3) }
      example_with(_shared: { s1: [] })           { expect(self).to have_included(:s1).with }
      example_with(_shared: { s1: [:a1, :a2] })   { expect(self).to have_included(:s1).with(:a1, :a2) }
      example_with(_shared: { s1: { a1: 1 } })    { expect(self).to have_included(:s1).with(a1: 1) }
      example_with(_shared: { s1: [:a1, a2: 2] }) { expect(self).to have_included(:s1).with(:a1, a2: 2) }
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

      context_with _meta: { m1: "3" } do
        example { |e| expect(e).to have_metadata(:m1).with("3") }
      end

      context_with _meta: [:m1, m2: 3] do
        example { |e| expect(e).to have_metadata(:m1).with(true) }
        example { |e| expect(e).to have_metadata(:m2).with(3) }
      end
    end

    describe "shared context" do
      context_with _shared: :s1 do
        example { expect(self).to have_included(:s1).with }
        example { expect(self).not_to have_included(:s2) }
      end

      context_with _shared: [:s1, :s2] do
        example { expect(self).to have_included(:s1).with }
        example { expect(self).to have_included(:s2).with }
      end

      context_with _shared: { s1: "3" } do
        example { expect(self).to have_included(:s1).with("3") }
      end

      context_with _shared: [:s1, s2: 3] do
        example { expect(self).to have_included(:s1).with }
        example { expect(self).to have_included(:s2).with(3) }
      end

      context_with _shared: { s1: [] } do
        example { expect(self).to have_included(:s1).with }
      end

      context_with _shared: { s1: [:a1, :a2] } do
        example { expect(self).to have_included(:s1).with(:a1, :a2) }
      end

      context_with _shared: { s1: { a1: 1 } } do
        example { expect(self).to have_included(:s1).with(a1: 1) }
      end

      context_with _shared: { s1: [:a1, a2: 2] } do
        example { expect(self).to have_included(:s1).with(:a1, a2: 2) }
      end
    end
  end
end
