#!/usr/bin/env ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class Register

    def initialize(bundles=[])
      @bundles = bundles
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

      vmi_dir = "#{VM2.image_repository_path}/#{vmi}"

      FileUtils.mkdir_p vmi_dir

      Dir.chdir( vmi_dir ) do 
        puts Dir.pwd
        command = "tar zxvf #{bundle} --strip-components 1"
        puts command
        Open3.popen3( command ) do |stdin, stdout, stderr|
          while ( ! ( l = stdout.gets ).nil? )
            puts l
          end
        end
      end

      vmx = File.basename( Dir[ vmi_dir + "/*.vmx" ].first )
      puts "vmx [#{vmx}]"
      data[ vmi ] = vmx
      VM2.image_repository_data = data
    end

    def self.parse(args)
      return args
    end 
end

