require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class StartInstances

  ROOT_PASSWORD='oddthesis'

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
    vm2_support_file = "#{instance_dir}/vm2-support.conf"
    FileUtils.rm_f( vm2_support_file )
    `#{VM2.vmrun_path} start #{instance_vmx} nogui`
    if ( File.exist?( "#{instance_dir}/vm2-user-data.conf" ) )
      `#{VM2.vmrun_path} -gu root -gp #{ROOT_PASSWORD} copyFileFromHostToGuest #{instance_vmx} #{instance_dir}/vm2-user-data.conf /etc/vm2-user-data.conf`
    end
    `#{VM2.vmrun_path} -gu root -gp #{ROOT_PASSWORD} runProgramInGuest #{instance_vmx} /sbin/vm2-support`
    `#{VM2.vmrun_path} -gu root -gp #{ROOT_PASSWORD} copyFileFromGuestToHost #{instance_vmx} /etc/vm2-support.conf #{vm2_support_file}`
  end

  def self.parse(args)
    options = OpenStruct.new
    options.instance_ids = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 start-instances <instance-id> [ instance-id ]"

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

