require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class RebootInstances

  def initialize(opts={})
    @instance_ids = opts.instance_ids || []
  end

  def run
    @instance_ids.each do |instance_id|
      reboot_instance( instance_id )
    end
  end

  def reboot_instance(instance_id)
    instance_dir = "#{VM2.instance_repository_path}/#{instance_id}"
    instance_vmx = Dir[ "#{instance_dir}/*.vmx" ].first
    puts "rebooting with #{instance_vmx}"
    puts "#{VM2.vmrun_path} reset #{instance_vmx}"
    puts `#{VM2.vmrun_path} reset #{instance_vmx}`
  end

  def self.parse(args)
    options = OpenStruct.new
    options.instance_ids = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 reboot-instances <instance-id> [ instance-id ]"

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
    options.instance_ids = args
    options
  end 
end

