# frozen_string_literal: true

require "rspec"

require_relative "context_helper/version"

module RSpec
  module ContextHelper
    def context_with(description = nil, metadata: nil, shared: nil, **values, &block)
      description ||= to_sentence(values.map { |k, v| "#{k} is #{v.inspect}" }).then do |desc|
        desc.empty? ? desc : "when #{desc}"
      end

      context description do
        values.each do |key, value|
          let(key) do
            value.is_a?(::Proc) ? instance_exec(&value) : value
          end
        end
        instance_exec(&block)
      end
    end

    def example_with(description = nil, metadata: nil, shared: nil, **values, &block)
      context_with(description, metadata: metadata, shared: shared, **values) do
        example { instance_exec(&block) }
      end
    end

    private def to_sentence(words)
      case words.size
      when 0
        ""
      when 1
        words[0]
      when 2
        words.join(" and ")
      else
        *rest, last = words
        [rest.join(", "), last].join(" and ")
      end
    end
  end
end

RSpec.configure do |config|
  config.extend RSpec::ContextHelper
end
