require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require 'sha1'

require 'yaml'
require 'open3'

class Deregister

  def initialize(opts={})
    @vmis = opts.vmis
  end

  def run
    @vmis.each{|vmi| deregister( vmi ) }
  end

  def deregister(vmi)
    data = VM2.image_repository_data

    if ( data[vmi].nil? )
      puts "not registered: #{vmi}"
      return
    end

    puts "deregistering: #{vmi}"

    data.delete( vmi )

    VM2.image_repository_data = data

    repository_bundle = "#{VM2.image_repository_path}/#{vmi}.tar.gz"
    FileUtils.rm_rf( repository_bundle )
  end

  def self.parse(args)
    options = OpenStruct.new
    options.vmis = []

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vm2 deregister <vmi>"

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
    options.vmis = args
    options
  end
end

