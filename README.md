# 👷‍🕳 HashDigger

> A utilitarian lib to extract data from complex Hashes using String path with "recursions".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hash_digger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hash_digger

## Usage

````ruby
  _h  = {a: 1, b: 2}
  p HashDigger::Digger.dig(data: _h, path: '*') # => {:a=>1, :b=>2}
  p HashDigger::Digger.dig(data: _h, path: 'b') # => 2

  _a  = [1, 2, 3]
  p HashDigger::Digger.dig(data: _a, path: '*') # => [1, 2, 3]
  p HashDigger::Digger.dig(data: _a, path: '2') # => 3

  ah  = [{a: 42}, {a: 13, b: 7}]
  p HashDigger::Digger.dig(data: ah, path: '*.a') # => [42, 13]
  p HashDigger::Digger.dig(data: ah, path: '*.b', strict: false) # => [nil, 7]
  p HashDigger::Digger.dig(data: ah, path: '*.b', strict: false) { |result| result.compact } # => [7]

  ha  = {a: [1, 2, 3], b: [4, 5, 6]}
  p HashDigger::Digger.dig(data: ha, path: '*') # => {:a=>[1, 2, 3], :b=>[4, 5, 6]}
  p HashDigger::Digger.dig(data: ha, path: 'a.2') # => 3
  p HashDigger::Digger.dig(data: ha, path: 'b.0') # => 4

  aha = [{a: 42, b: 13}, [1, 2, 3]]
  p HashDigger::Digger.dig(data: aha, path: '*') # => [{:a=>42, :b=>13}, [1, 2, 3]]
  p HashDigger::Digger.dig(data: aha, path: '*.0', strict: false) # => [nil, 1]

  hah = {a: [1, 2, 3], b: {a: 13, b: 42}}
  p HashDigger::Digger.dig(data: hah, path: '*') # => {:a=>[1, 2, 3], :b=>{:a=>13, :b=>42}}
  p HashDigger::Digger.dig(data: hah, path: 'a') # => [1, 2, 3]
  p HashDigger::Digger.dig(data: hah, path: 'a.*') # => [1, 2, 3]
  p HashDigger::Digger.dig(data: hah, path: 'b.b') # => 42

  aah = [[{a: 1}, {b: 2}], [{a: 1}, {c: 3}]]
  p HashDigger::Digger.dig(data: aah, path: '*.*.a', strict: false) # => [1, nil, 1, nil]
  p HashDigger::Digger.dig(data: aah, path: '*.*.a', strict: false) { |result| result.compact } # => [1, 1]

  hhh = {a: {b: {c: {d: 'data'}}}}
  p HashDigger::Digger.dig(data: hhh, path: 'a.b.c.d') # => "data"

  # => Correct error being raised! YAY! HashDigger::DigError
  begin
    p HashDigger::Digger.dig(data: hhh, path: 'a.b.z.d')
  rescue HashDigger::DigError => e
    puts "Correct error being raised! YAY! #{e.class}"
  end

  hahah = {a: {b: 42 }, c: [{d: [{test: 'ok'}, {test: 'well'}]}]}
  p HashDigger::Digger.dig(data: hahah, path: 'c.*.d.*') # => [[{:test=>"ok"}, {:test=>"well"}]]
  p HashDigger::Digger.dig(data: hahah, path: 'c.*.d.*.*') # => [{:test=>"ok"}, {:test=>"well"}]

  hhhah = {a: {b: {c: {d: [{info: 42}, {info: 13}, {something: 'test'}]}}}}
  p HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.info', strict: false) # => [42, 13, nil]
  p HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.info', strict: false, default: '<ERROR>') # => [42, 13, "<ERROR>"]
  p HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.something', strict: false) # [nil, nil, "test"]

  p (HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.something', strict: false) do |result|
    result.map {|node| node.nil? ? 'OK' : node }
  end) # ["OK", "OK", "test"]
````

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smileart/hash_digger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HashDigger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smileart/hash_digger/blob/master/CODE_OF_CONDUCT.md).
