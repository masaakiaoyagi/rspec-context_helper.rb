# frozen_string_literal: true

RSpec.describe RSpec::ContextHelper do
  let(:description) { self.class.description }

  describe ".context_with" do
    describe "description" do
      context_with do
        example { expect(description).to eq("") }
      end

      context_with "message" do
        example { expect(description).to eq("message") }
      end

      context_with a: "1" do
        example { expect(description).to eq(%(when a is "1")) }
      end

      context_with a: "1", b: "2" do
        example { expect(description).to eq(%(when a is "1" and b is "2")) }
      end

      context_with a: "1", b: "2", c: "3" do
        example { expect(description).to eq(%(when a is "1", b is "2" and c is "3")) }
      end
    end

    context_with do
      example {}
    end

    context_with "message" do
      example {}
    end

    context_with a: "1" do
      example { expect(a).to eq("1") }
    end

    context_with "message", a: -> { b }, b: "2", c: -> { -> {} } do
      example { expect(a).to eq("2") }
      example { expect(b).to eq("2") }
      example { expect(c).to be_an_instance_of(Proc) }
    end
  end

  describe ".example_with" do
    describe "description" do
      example_with do
        expect(description).to eq("")
      end

      example_with "message" do
        expect(description).to eq("message")
      end

      example_with a: "1" do
        expect(description).to eq(%(when a is "1"))
      end

      example_with a: "1", b: "2" do
        expect(description).to eq(%(when a is "1" and b is "2"))
      end

      example_with a: "1", b: "2", c: "3" do
        expect(description).to eq(%(when a is "1", b is "2" and c is "3"))
      end
    end

    example_with do
    end

    example_with "message" do
    end

    example_with a: "1" do
      expect(a).to eq("1")
    end

    example_with "message", a: -> { b }, b: "2", c: -> { -> {} } do
      expect(a).to eq("2")
      expect(b).to eq("2")
      expect(c).to be_an_instance_of(Proc)
    end
  end
end
