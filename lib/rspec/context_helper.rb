# frozen_string_literal: true

require "rspec"

require_relative "context_helper/version"

module RSpec
  module ContextHelper
    module DSL
      def example_with(description = nil, _meta: nil, _shared: nil, **values, &block)
        context_with(description, _meta: _meta, _shared: _shared, **values) do
          example { |*args| instance_exec(*args, &block) }
        end
      end

      def context_with(description = nil, _meta: nil, _shared: nil, **values, &block)
        tags, metadata = Utils.split_options(_meta)
        shared = Utils.to_h(_shared)
        description ||= Utils.to_description(tags, metadata, shared, values)

        context description, *tags, **metadata do
          shared.each do |name, _args|
            args, opts = Utils.split_options(_args)
            include_context name, *args, **opts
          end
          values.each do |key, value|
            let(key) do
              value.is_a?(::Proc) ? instance_exec(&value) : value
            end
          end
          instance_exec(&block)
        end
      end
    end

    module Utils
      class << self
        def split_options(value)
          if value.is_a?(::Hash)
            [[], value]
          else
            value = Array(value)
            value.last.is_a?(::Hash) ? [value, value.pop] : [value, {}]
          end
        end

        def to_h(value)
          case value
          when nil
            {}
          when ::Array
            *rest, last = value
            if last.is_a?(::Hash)
              rest.map { |i| [i, nil] }.to_h.merge(last)
            else
              value.map { |i| [i, nil] }.to_h
            end
          when ::Hash
            value
          else
            { value => nil }
          end
        end

        def to_description(tags, metadata, shared, values)
          to_sentence(to_tag_words(tags) + to_metadata_words(metadata) + to_shared_words(shared) + to_values_words(values)).then do |desc|
            desc.empty? ? desc : "when #{desc}"
          end
        end

        # TODO: whether to include tag in the description
        private def to_tag_words(tags)
          []
        end

        # TODO: whether to include metadata in the description
        private def to_metadata_words(metadata)
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
