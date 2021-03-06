require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

require 'start-instances'

class RunInstances

  def initialize(opts={})
    @vmi = opts.vmi 
    @instance_count = opts.instance_count || 1
    @user_data = opts.user_data
  end

  def run
    if ( @vmi.nil? )
      puts "No image specified"
      return
    end
    vmi_bundle = VM2.image_repository_path + "/#{@vmi}.tar.gz"
    if ( ! File.exists?( vmi_bundle ) )
      puts "No such image in repository: #{vmi_bundle}"
      return
    end

    instances = [] 
    1.upto( @instance_count ) do |i|
      instances << prepare_instance( @vmi, vmi_bundle, i ) 
    end

    threads = []
    instances.each do |instance|
      threads << start_instance( instance )
    end

    threads.each{|t| t.join}
  end

  def start_instance(instance)
    Thread.new() {
      StartInstances.new( OpenStruct.new( :instance_ids=>[ instance.instance_id ] ) ).run
    }
  end

  def prepare_instance(vmi, vmi_bundle, i) 
    instance_id = create_instance_id(vmi_bundle, i)

    instance_dir = VM2.instance_repository_path + "/#{instance_id}"
    FileUtils.mkdir_p( instance_dir )

    image_conf = {
      :vmi=>vmi,
      :created=>Time.now,
      :user=>ENV['USER']
    }
    File.open( "#{instance_dir}/vm2-image.conf", 'w' ) { |f| f.write( YAML.dump( image_conf ) ) }

    unless ( @user_data.nil? )
      File.open( "#{instance_dir}/vm2-user-data.conf", 'w' ) { |f| f.write( @user_data ) }
    end

    expand_bundle( vmi_bundle, instance_dir )

    instance_vmx = Dir[ "#{instance_dir}/*.vmx" ].first
    if ( instance_vmx.nil? )
      puts "Error: unable to locate .vmx in #{instance_dir}"
      return
    end

    instance_data = OpenStruct.new( :dir=>instance_dir, :instance_id=>instance_id, :vmx=>instance_vmx )
  end

  def inject_user_data(instance_vmx)
  end

  def expand_bundle(vmi_bundle, instance_dir)
    Dir.chdir( instance_dir ) do
      Open3.popen3( "tar zxvf #{vmi_bundle} --strip-components 1" ) do |stdin, stdout, stderr|
        while ( ( l = stdout.gets ) != nil )
          # nothing
        end
      end
    end
    File.open( "#{instance_dir}/vm2.prepared", 'w' ) {|f| f.puts( Time.now )}
  end

  def create_instance_id(vmi_bundle, i)
    instance_id = nil
    while ( instance_id.nil? )
      instance_raw = "#{Time.now}-#{ENV['USER']}-#{vmi_bundle}-#{i}"
      instance_sha1 = SHA1.hexdigest( instance_raw )
      short_sha1 = instance_sha1[0,10]
      instance_id = "i-#{short_sha1}"
      if ( File.exist?( VM2.instance_repository_path + "/#{instance_id}" ) )
        instance_id = nil
      end
    end
    return instance_id
  end

  def self.parse(args)
    options = OpenStruct.new
    options.vmi = nil
    options.instance_count = 1
    options.user_data = nil
    options.user_data_file = nil

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 run-instances <ami> [OPTIONS]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on( "-n", "--instance-count NUM", Integer,
               "Specify the number of instances to launch" ) do |instance_count|
        options.instance_count = instance_count
      end

      opts.on( "-d", "--user-data DATA", 
               "Specify the launch user-data" ) do |user_data|
        options.user_data = user_data
      end
      opts.on( "-f", "--user-data-file FILE", 
               "Specify the launch user-data as a file" ) do |user_data_file|
        options.user_data_file = user_data_file
      end
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
    if ( args.size == 1 )
      options.vmi = args.first 
    end

    if ( ! options.user_data.nil? && ! options.user_data_file.nil? )
      puts "Error: only one of --user-data or --user-data-file may be specified"
      exit 1
    end

    if ( ! options.user_data_file.nil? )
      if ( ! File.exists?( options.user_data_file ) )
        puts "Error: no file #{options.user_data_file}"
        exit 1
      end
      options.user_data = File.read( options.user_data_file )
    end

    options
  end 
end

