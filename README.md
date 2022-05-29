# RSpec::ContextHelper

[![test](https://github.com/masaakiaoyagi/rspec-context_helper.rb/actions/workflows/test.yml/badge.svg)](https://github.com/masaakiaoyagi/rspec-context_helper.rb/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This helper library is for writing tests concisely.

You can write a test as follows.
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

That's basically all there is to it, but I think it will be more potent when used with a [custom matcher](https://relishapp.com/rspec/rspec-expectations/v/3-11/docs/custom-matchers).

<details>
<summary>
Example of ActiveModel validation tests using a custom matcher
</summary>
<div>

```ruby
class Account
  include ActiveModel::Model
  include ActiveModel::Attributes
  attribute :name, :string
  validates :name, presence: true, length: { in: 3..20 }, format: { with: /\A[0-9a-zA-Z]*\z/, message: "alphanumeric characters only" }
end

let(:account) { Account.new(name: name) }
before do
  account.valid?
end

# There is no "have_error" matcher, so you need to create one.
example_with(name: " ")      { expect(account).to have_error.on(:name).with(:blank) }
example_with(name: "a" * 2)  { expect(account).to have_error.on(:name).with(:too_short, count: 3) }
example_with(name: "a" * 3)  { expect(account).not_to have_error }
example_with(name: "a" * 20) { expect(account).not_to have_error }
example_with(name: "a" * 21) { expect(account).to have_error.on(:name).with(:too_long, count: 20) }
example_with(name: "a0a")    { expect(account).not_to have_error }
example_with(name: "a a")    { expect(account).to have_error.on(:name).with(:invalid) }
example_with(name: "a@a")    { expect(account).to have_error.on(:name).with("alphanumeric characters only") }
```
</div>
</details>

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
* [Crystal version](https://github.com/masaakiaoyagi/spectator-context_helper.cr)
