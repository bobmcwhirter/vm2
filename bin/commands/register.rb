#!/usr/bin/env ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class Register

  def initialize(opts={})
    @bundles = opts.bundles
  end

  def run
    @bundles.each{|b| register( b ) }
  end

  def register(bundle)
    simple_name = File.basename( File.basename( bundle, ".tgz" ), ".tar.gz" )
    sha1 = SHA1.hexdigest( File.read( bundle ) )
    short_sha1 = sha1[0,10]
    vmi = "vmi-#{short_sha1}"

    data = VM2.image_repository_data

    if ( ! data[vmi].nil? )
      puts "already registered as #{vmi}"
      return
    end

    puts "registering #{simple_name} as #{vmi}"

    repository_bundle = "#{VM2.image_repository_path}/#{vmi}.tar.gz"

    FileUtils.cp bundle, repository_bundle

    data[ vmi ] = {
      'registered'=>Time.now,
      'name'=>simple_name,
      'user'=>ENV['USER'],
    }

    VM2.image_repository_data = data
  end

  def self.parse(args)
    options = OpenStruct.new
    options.bundles = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 register <bundle.tar.gz>"

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

    end

    opts.parse!(args)
    options.bundles = args
    options
  end 
end

