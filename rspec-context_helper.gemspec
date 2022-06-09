# frozen_string_literal: true

require_relative "lib/rspec/context_helper/version"

Gem::Specification.new do |spec|
  spec.name = "rspec-context_helper"
  spec.version = RSpec::ContextHelper::VERSION
  spec.authors = ["Masaaki Aoyagi"]
  spec.email = ["masaaki.aoyagi@gmail.com"]

  spec.summary = "context helpers for RSpec"
  spec.description = "context helpers for RSpec"
  spec.homepage = "https://github.com/masaakiaoyagi/rspec-context_helper.rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  # spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec"
end
