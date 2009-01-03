#!/usr/bin/env ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class Info

  def initialize(opts={})
  end

  def run
    puts "Size of repository:"
    puts "  Images:    #{`du -sh #{VM2.image_repository_path}`.strip} for #{`ls -1 #{VM2.image_repository_path} | wc -l `.strip} images"
    puts "  Instances: #{`du -sh #{VM2.instance_repository_path}`.strip} for #{`ls -1 #{VM2.instance_repository_path} | wc -l `.strip} instances"
  end
  
  def self.parse(args)
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 info"

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
    options

  end  # parse()
end

