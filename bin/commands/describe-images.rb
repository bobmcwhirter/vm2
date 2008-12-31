#!/usr/bin/env ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class DescribeImages

  def initialize(opts={})
    @all  = opts.all  || nil
    @vmis = (opts.vmis || []).uniq
  end

  def run
    data = VM2.image_repository_data
    count = 0
    print_header
    if ( @all || @vmis.empty? )
      data.each do |vmi, vmi_data|
        print_describe( vmi, vmi_data )
        count += 1
      end
    else
      @vmis.each do |vmi|
        vmi_data = data[vmi]
        if ( vmi_data )
          print_describe( vmi, vmi_data )
          count += 1
        end
      end
    end
    print_footer( count )
  end
  
  def print_header()
    puts "VMI             Name                                     User         Date"
    puts "----------------------------------------------------------------------------------------------------"
  end
  def print_describe(vmi, vmi_data)
    puts "#{vmi}  #{sprintf( "%-40s", vmi_data['name'][0,40])} #{sprintf( "%-12s", vmi_data['user'][0,12])} #{vmi_data['registered']}"
  end

  def print_footer(count)
    puts "----------------------------------------------------------------------------------------------------"
    puts "#{count} images"
  end

  def self.parse(args)
    options = OpenStruct.new
    options.all = false
    options.vmis = []

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
    options.vmis = args
    options

  end  # parse()
end

