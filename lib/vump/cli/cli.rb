require 'vump/vump'
require 'time'

module Vump
  module CLI
    def self.parse_args(inputs) # rubocop:disable Metrics/MethodLength
      options = {}
      args = []
      inputs.each do |input|
        case input
        when /--(?<key>.*?)=(?<value>.*)/
          options[Regexp.last_match(1).to_sym] = Regexp.last_match(2)
        when /--?(.*)/
          options[Regexp.last_match(1).to_sym] = true
        else
          args << input
        end
      end
      [args, options]
    end

    def self.parse_inputs(inputs)
      args, options = parse_args(inputs)
      [parse_arg(args), parse_options(options)]
    end

    def self.parse_arg(args)
      case args.first
      when /^ma.*/
        :major
      when /^mi.*/
        :minor
      else
        :patch
      end
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def self.parse_options(options)
      defaults = {
        date: Time.now,
        silent: false,
        version: false,
        tag_prefix: 'v',
        path: Dir.pwd,
      }
      options.keys.each_with_object(defaults) do |k, acc|
        case k
        when :s, :silent
          acc[:silent] = options[k]
        when :v, :version
          acc[:version] = options[k]
        when :t, :tag_prefix, :'tag-prefix'
          acc[:tag_prefix] = options[k]
        when :b, :build
          acc[:build] = options[k]
        when :pre
          acc[:pre] = options[k]
        when :d, :date
          acc[:date] = Time.parse(options[k]) rescue defaults[:date]
        when :p, :path
          acc[:path] = options[k]
        else
          acc[k] = options[k]
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def self.start(inputs)
      arg, opts = parse_inputs(inputs)
      vump = ::Vump::Vump.new(opts[:path], arg, opts)
      vump.start
    end
  end
end
