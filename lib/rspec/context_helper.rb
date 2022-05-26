# frozen_string_literal: true

require "rspec"

require_relative "context_helper/version"

module RSpec
  module ContextHelper
    module DSL
      def context_with(description = nil, metadata: nil, shared: nil, **values, &block)
        shared = Utils.to_h(shared)
        description ||= Utils.to_description(metadata, shared, values)

        context description, *metadata do
          shared.each do |name, args|
            include_context name, *args
          end
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
          example { |*args| instance_exec(*args, &block) }
        end
      end
    end

    module Utils
      class << self
        def to_h(value)
          case value
          when nil
            {}
          when Array
            *rest, last = value
            if last.is_a?(Hash)
              rest.map { |i| [i, nil] }.to_h.merge(last)
            else
              value.map { |i| [i, nil] }.to_h
            end
          when Hash
            value
          else
            { value => nil }
          end
        end

        def to_description(metadata, shared, values)
          to_sentence(to_metadata_words(metadata) + to_shared_words(shared) + to_values_words(values)).then do |desc|
            desc.empty? ? desc : "when #{desc}"
          end
        end

        # TODO: whether to include metadata in the message
        private def to_metadata_words(metadata)
          # to_h(metadata).map { |k, v| k }
          []
        end

        private def to_shared_words(shared)
          shared.map { |k, v| k }
        end

        private def to_values_words(values)
          values.map { |k, v| "#{k} is #{v.inspect}" }
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
  end
end

RSpec.configure do |config|
  config.extend RSpec::ContextHelper::DSL
end
