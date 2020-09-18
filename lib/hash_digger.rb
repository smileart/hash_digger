require 'ruby-try'
require 'stringio'
require 'amazing_print'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'

require 'byebug' if ENV['DEBUG']

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
          # *.* stands for "flatten the top level arrays until there's one * left
          # which means iterate the fetcher with the following path over the result of the flattening"
          while path.fetch(0) === '*' && path&.fetch(1, nil) === '*' do
            data = data.flatten(1)
            path.shift
          end

          # if the path ends with a "*" and that's it
          return (block_given? ? yield(data) : data) if path.length === 1 && path.fetch(0) === '*'

          subpath = path.shift

          if subpath === '*'
            subpath = path.shift
            data = data&.collect {|node| fetch(data: node, path: subpath, strict: strict, default: default) }
          else
            data = fetch(data: data, path: subpath, strict: strict, default: default)
          end
        end

        # return data or apply the custom block handler to the whole result
        return (block_given? ? yield(data) : data)
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

        path
      end
    end
  end
end