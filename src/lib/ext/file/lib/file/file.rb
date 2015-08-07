class File < IO
  include ::IO::Writable
  include ::IO::Readable
  @delg = VRbJS::File
  def self.read path
    @delg.read(path)
  end

  def self.exist? path
    @delg.exist(path)
  end

  def self.realpath(pathname, dir_string = nil, cache = nil, &block)
    pathname = join(dir_string, pathname) if dir_string
    raise NotImplementedError
  end

  def self.basename(path, ext = undefined)
    @delg.basename(path, ext)
  end

  def self.dirname(path)
    @delg.dirname(path)
  end

  def self.join(*paths)
    @delg.join(*paths)
  end

  def self.directory? path
    return nil unless exist? path
    `!!__fs__.lstatSync(path).isDirectory()`
  end

  def self.file? path
    return nil unless exist? path
    @delg.is_file path
  end

  def self.size path
    return nil unless exist? path
    @delg.size(path)
  end

  def self.open path, flags, &b
    @delg.open(path, flags) do |n|
      new(path, flags, n)
    end
  end




  # Instance Methods
  def initialize(path, flags, delg = nil)
    flags = flags.gsub(/b/, '')
    @path = path
    @flags = flags
    
    @delg = delg || VRbJS::File.new(path, flags)
  end

  attr_reader :path

  def write string
    @delg.write string
  end

  def flush
    @delg.flush
  end

  def close
    @delg.close
  end
  
  def each &b
    @delg.each &b
  end
end
