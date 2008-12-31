require 'fileutils'

require 'yaml'

module VM2

  def self.vmrun_path
    '/Library/Application\ Support/VMware\ Fusion/vmrun'
  end

  def self.repository_path
    ENV['HOME'] + '/.vm2'
  end

  def self.image_repository_path
    VM2.repository_path + "/images"
  end

  def self.instance_repository_path
    VM2.repository_path + "/instances"
  end

  def self.prepare_repository
    FileUtils.mkdir_p VM2.image_repository_path
    FileUtils.mkdir_p VM2.instance_repository_path
  end

  def self.image_repository_data
    if ( File.exist?( VM2.image_repository_path + "/images.yml" ) )
      return YAML.load_file( VM2.image_repository_path + "/images.yml" )
    end
    return {}
  end

  def self.image_repository_data=(data)
    File.open( VM2.image_repository_path + "/images.yml", 'w' ) {|f| f.write( YAML.dump( data ) )}
  end

end
