require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class ShutdownInstances

  def initialize(opts={})
    @instance_ids = opts.instance_ids || []
  end

  def run
    @instance_ids.each do |instance_id|
      shutdown_instance( instance_id )
    end
  end

  def shutdown_instance(instance_id)
    instance_dir = "#{VM2.instance_repository_path}/#{instance_id}"
    instance_vmx = Dir[ "#{instance_dir}/*.vmx" ].first
    puts "shutting down with #{instance_vmx}"
    `#{VM2.vmrun_path} -gu root -gp thincrust runProgramInGuest #{instance_vmx} /sbin/shutdown -h now`
  end

  def self.parse(args)
    options = OpenStruct.new
    options.instance_ids = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 shutdown-instances <instance-id> [ instance-id ]"

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

