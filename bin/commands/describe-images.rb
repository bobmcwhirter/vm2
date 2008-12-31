#!/usr/bin/env ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class DescribeImages

    def initialize(opts)
      @opts = opts
    end

    def run
      data = VM2.image_repository_data
      data.keys.each do |ami|
        puts ami
      end
    end

    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.

      options = OpenStruct.new
      options.all = false
      options.images = []

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-a", "--all", "Describe all images") do |a|
          options.all = a
        end

        opts.separator ""
        opts.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts OptionParser::Version.join('.')
          exit
        end
      end

      opts.parse!(args)
      options.images = args
      options
    end  # parse()
end

#puts DescribeImages.parse( ARGV ).inspect
