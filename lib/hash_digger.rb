require 'hash_digger/version'

require 'ruby-try'
require 'pp'
require 'rubygems'
require 'ruby_dig'
require 'active_support/core_ext/hash/indifferent_access'

# Test test tst
module HashDigger
  class Error < IndexError; end

  class Digger
    # Actuall digging
    def self.dig(data:, path:, &filter)
      return data unless path

      if data.respond_to?(:keys)
        #               ⬇ for hash itself      ⬇ for hashes in arrays
        data = data.with_indifferent_access.deep_symbolize_keys
      end

      if path.is_a? String
        path = parse_path(data, path)
        data = data.dig(*path.shift)
      end

      return data if path.empty?
      return unless data.is_a?(Array)

      current_path = path.shift
      data_subset = []

      data.each do |e|
        begin
          if path.empty? && block_given?
            data_subset << e.dig(*current_path) if e && yield(data, e)
          else
            data_subset << e.dig(*current_path) if e
          end
        rescue TypeError
          process_dig_index_exception(data, current_path)
        end
      end

      unless path.empty?
        clean_data_subset = data_subset.reject(&:nil?).reject(&:empty?)
        data_subset = data_subset.reject(&:nil?).flatten until data_subset[0].is_a?(Hash) || clean_data_subset.empty?
      end

      dig(data: data_subset, path: path, &filter)
    end

    private

    # Handle wrong paths Exceptions and print the error
    def self.process_dig_index_exception(data, current_path)
      str_io = StringIO.new
      $stdout = str_io

      pp data
      line = "\n#{'-'*70}\n"
      pp_data = "#{line}#{$stdout.string}#{line}"

      $stdout = STDOUT

      raise Error, "There is no `#{current_path.join(' > ')}` path in #{pp_data}"
    end

    def self.parse_path(data, path)
      are_symbol_keys = data.keys.first.is_a? Symbol

      path = path.try(:split, '*')
      path.collect do |dp|
        dig_path = dp.try(:split, '.').compact.try(:map) do |p|
          if p =~ /^[\d]+$/
            p.to_i
          else
            if are_symbol_keys
              p.to_sym
            else
              p.to_s
            end
          end
        end

        dig_path.reject! do |p|
          p.empty? unless p.is_a? Integer
        end

        dig_path.flatten
      end
    end
  end
end
