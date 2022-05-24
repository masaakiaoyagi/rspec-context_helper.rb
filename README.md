# RSpec::ContextHelper

[![test](https://github.com/masaakiaoyagi/rspec-context_helper.rb/actions/workflows/test.yml/badge.svg)](https://github.com/masaakiaoyagi/rspec-context_helper.rb/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This helper library is for writing tests concisely.

For example,
```ruby
example_with("value is zero", value: 0) { expect(value).to eq 0 }
```
Above is the same as below.
```ruby
context "value is zero" do
  let(:value) { 0 }
  it { expect(value).to eq 0 }
end
```

That's basically all there is to it, but I think it will be more potent when used with a custom matcher.

Also, [the Crystal version](https://github.com/masaakiaoyagi/spectator-context_helper.cr) is available.

## Installation

1. Add the dependency to your `Gemfile`:

    ```ruby
    group :test do
      gem "rspec-context_helper"
    end
    ```

1. Run `bundle install`

## Usage

```ruby
require "rspec-context_helper"
```

See [spec](https://github.com/masaakiaoyagi/rspec-context_helper.rb/blob/main/spec/rspec/context_helper_spec.rb) how to write a test.

## Development

### Run tests
```sh
$ docker compose run --rm 3.1 bundle exec rspec
```

## See also
* [RSpec](https://github.com/rspec/rspec-metagem)
