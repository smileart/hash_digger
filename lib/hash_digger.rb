require 'hash_digger/version'

require 'ruby-try'
require 'awesome_print'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'

require 'byebug' if ENV['DEBUG']
require 'letters' if ENV['DEBUG']

module HashDigger
  class DigError < Exception; end

  class Digger
    class << self
      def dig(data:, path:, strict: true, default: nil)
        if data.respond_to?(:keys)
          data = data.deep_symbolize_keys
        end

        # form the path of non enumerable diggable groups
        path = path(path)

        until path.empty? do
          while path.fetch(0) === '*' && path.fetch(1) === '*' do
            data = data.flatten(1)
            path.shift
          end

          subpath = path.shift

          if subpath === '*'
            subpath = path.shift
            data = data.collect {|node| fetch(data: node, path: subpath, strict: strict, default: default) }
          else
            data = fetch(data: data, path: subpath, strict: strict, default: default)
          end
        end

        return data unless block_given?

        # with custom block handler on whole result
        return yield(data)
      end

      private

      def fetch(data:, path:, strict:, default: nil)
        path.reduce(data) { |node, key|
          node != default ? (node&.fetch(key) { |key| strict ? (raise DigError) : default }) : node
        }
      rescue KeyError, TypeError, DigError => e
        return default unless strict

        line = "#{'-'*70}\n"

        # ==== START ::: Intercept Awesome Print output =====
        # TODO: Fix STDOUT interception with threads in mind!!!
        str_io = StringIO.new
        $stdout = str_io

        ap data
        ap_data = "#{line}#{$stdout.string}#{line}"

        $stdout = STDOUT
        # ==== END ::: Intercept Pretty Print output =====

        raise DigError, "\nThere is no `#{path.join(' > ')}` path in some of the children:\n#{ap_data}"
      end

      def path(path)
        path = path.try(:split, '*')

        # split subgroups by "." and coerce types
        path = path.collect do |dp|
          dig_path = dp.try(:split, '.').compact.try(:map) do |p|
            (p =~ /^[\d]+$/) ? p.to_i : p.to_sym
          end

          dig_path.reject! do |p|
            p.try(:blank?)
          end

          dig_path.flatten
        end

        return path if path.length === 1

        path = path.map {|e| e === [] ? ['*'] : [e, '*']}.flatten(1)

        return path unless path.last === '*'

        path.pop
        path
      end
    end
  end
end

if $0 === __FILE__
  _h  = {a: 1, b: 2}
  _a  = [1, 2, 3]
  ah  = [{a: 42}, {a: 13, b: 7}]
  ha  = {a: [1, 2, 3], b: [4, 5, 6]}
  aha = [{a: 42, b: 13}, [1, 2, 3]]
  hah = {a: [1, 2, 3], b: {a: 13, b: 42}}
  aah = [[{a: 1}, {b: 2}], [{a: 1}, {c: 3}]]
  hhh = {a: {b: {c: {d: 'data'}}}}
  hhhah = {a: {b: {c: {d: [{info: 42}, {info: 13}, {something: 'test'}]}}}}

  p HashDigger::Digger.dig(data: _h, path: '*')
  p HashDigger::Digger.dig(data: _h, path: 'b')

  p HashDigger::Digger.dig(data: _a, path: '*')
  p HashDigger::Digger.dig(data: _a, path: '2')

  p HashDigger::Digger.dig(data: ah, path: '*.a')
  p HashDigger::Digger.dig(data: ah, path: '*.b', strict: false)
  p HashDigger::Digger.dig(data: ah, path: '*.b', strict: false) { |result| result.compact }

  p HashDigger::Digger.dig(data: ha, path: '*')
  p HashDigger::Digger.dig(data: ha, path: 'a.2')
  p HashDigger::Digger.dig(data: ha, path: 'b.0')

  p HashDigger::Digger.dig(data: aha, path: '*')
  p HashDigger::Digger.dig(data: aha, path: '*.0', strict: false)

  p HashDigger::Digger.dig(data: hah, path: '*')
  p HashDigger::Digger.dig(data: hah, path: 'a')
  p HashDigger::Digger.dig(data: hah, path: 'a.*')
  p HashDigger::Digger.dig(data: hah, path: 'b.b')

  p HashDigger::Digger.dig(data: aah, path: '*.*.a', strict: false)
  p HashDigger::Digger.dig(data: aah, path: '*.*.a', strict: false) { |result| result.compact }

  p HashDigger::Digger.dig(data: hhh, path: 'a.b.c.d')

  begin
    p HashDigger::Digger.dig(data: hhh, path: 'a.b.z.d')
  rescue HashDigger::DigError => e
    puts "Correct error being raised! YAY! #{e.class}"
  end

  p HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.info', strict: false)
  p HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.info', strict: false, default: '<ERROR>')
  p HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.something', strict: false)
  p begin
    HashDigger::Digger.dig(data: hhhah, path: 'a.b.c.d.*.something', strict: false) do |result|
      result.map {|node| node.nil? ? 'OK' : node }
    end
  end

  require_relative '../test/fixtures/hash_digger'

  direct_path          = 'def.0.tr.0.ex.0.tr.0.text'
  ex_path              = 'def.*.tr.*.*.ex.*.*.text'
  tr_path              = 'def.*.tr.*.*.ex.*.*.tr.*.*.text'
  multi_word           = 'such a sucker.with his text!'
  wrong_path           = 'def.*.tr.*.ex.text'

  p HashDigger::Digger.dig(data: HashDiggerFixtures::DICTIONARY_SAMPLE_HASH[:test], path: direct_path, strict: false, default: '<NO DATA>')
  p HashDigger::Digger.dig(data: HashDiggerFixtures::DICTIONARY_SAMPLE_HASH[:test], path: ex_path, strict: false, default: '<NO DATA>')
  p HashDigger::Digger.dig(data: HashDiggerFixtures::DICTIONARY_SAMPLE_HASH[:test], path: tr_path, strict: false, default: '<NO DATA>')
  p HashDigger::Digger.dig(data: HashDiggerFixtures::DICTIONARY_SAMPLE_HASH[:test], path: multi_word, strict: false, default: '<NO DATA>')
  p HashDigger::Digger.dig(data: HashDiggerFixtures::DICTIONARY_SAMPLE_HASH[:test], path: wrong_path, strict: false, default: '<NO DATA>')
end