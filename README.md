# Sygna

[![Build Status](https://travis-ci.org/niclin/sygna-ruby.svg?branch=master)](https://travis-ci.org/niclin/sygna-ruby)

This is a Ruby library to help you build servers/servies within Sygna Bridge Ecosystem. For more detail information, please see [Sygna Bridge](https://www.sygna.io/).


## Installation instructions

If you are using Mac OS X and Homebrew, run these commands to install required development tools:

```
$ brew install autoconf automake libtool
```

Then download and install the library:

```
$ git clone https://github.com/bitcoin-core/secp256k1.git
$ cd secp256k1
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install
```

Add this line to your application's Gemfile:

```ruby
gem 'sygna'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sygna

## Usage

You need prepare private key first, like this

```
# The private key example:
# -----BEGIN EC PRIVATE KEY-----
# ...
# ...
# ...
# -----END EC PRIVATE KEY-----
```

initialize configure

```ruby
Sygna.configure do |config|
  config.api_key = "abcde12345"
  config.private_key = "Your private key"
end
```

### Private Info


#### Encode

```ruby
data = { name: "Nic" }
public_key_hex = "abcde12345"

Sygna::PrivateInfo.encode(data, public_key_hex)
# => encrypted string
```

#### Decode

```ruby
data = "qazwsxedc1234567890"

Sygna::PrivateInfo.decode(data)
# => decrypted string
```

### Signature

#### Sign

```ruby
object = { name: "Nic" }

Sygna::Signature.sign(object)

# => signatured string
```

#### Verify

```ruby
object = { name: "Nic" }
signature = "abcde12345"
public_key_hex = "originator public key"

Sygna::Signature.verify(object, signature, public_key_hex)

# => true or false
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/niclin/sygna.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
