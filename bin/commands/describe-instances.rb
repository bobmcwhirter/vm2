
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class DescribeInstances

  def initialize(opts={})
    @all          = opts.all          || false
    @instance_ids = opts.instance_ids || []
  end

  def run
    print_header
    if ( @all || @instance_ids.empty? )
      Dir[ VM2.instance_repository_path + "/i-*" ].each do |instance_dir|
        print_instance_line instance_dir
      end
    end
    print_footer
  end

  def print_header
    puts "Instance ID   VMI             State       IP Address        User                 Created"
    puts "---------------------------------------------------------------------------------------------------------------"
  end

  def print_footer
    puts "---------------------------------------------------------------------------------------------------------------"
  end

  def print_instance_line(instance_dir)
    instance_id = File.basename( instance_dir )
    state = state( instance_dir )
    ip_address = nil
    image_conf = YAML.load_file( "#{instance_dir}/vm2-image.conf" )
    if ( state == 'RUNNING' )
      ip_address = ip_address( instance_dir ) 
    end
    if ( state == 'RUNNING' && ip_address.nil? )
      state = 'STARTING'
    end
    puts "#{instance_id}  #{image_conf[:vmi]}  #{sprintf( '%-10s', state)}  #{sprintf("%-16s", ip_address||'-')}  #{sprintf("%-20s", image_conf[:user][0,20])} #{image_conf[:created]}"
  end

  def state(instance_dir)
    return 'PREPARING' unless ( File.exists?( "#{instance_dir}/vm2.prepared" ) )
    return 'RUNNING' unless ( Dir[ "#{instance_dir}/*.vmdk.lck" ].empty? ) 
    return 'STOPPED'
  end

  def ip_address(instance_dir)
    return nil unless ( File.exist?( instance_dir + "/vm2-support.conf" ) )
    File.open( instance_dir + "/vm2-support.conf" ) do |file|
      file.each_line do |line|
        name, value = line.split( "=" )
        name.strip!
        value.strip!
        return value if ( name == 'IP_ADDRESS' )
      end
    end
  end

  def self.parse(args)
    options = OpenStruct.new
    options.all = false
    options.instance_ids =  []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 describe-instances [ instance-id [ .. instance-id ] ] [ --all ]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on( "-a", "--all", 
               "Describe all instances" ) do |instance_count|
        options.all = true
      end

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

