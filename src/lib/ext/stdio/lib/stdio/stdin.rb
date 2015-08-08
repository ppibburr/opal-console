$stdin.extend IO::Readable
class << $stdin
  def io; @io ||= Stdin.wrap(`new Stdin()`); end 
  def readline
    io.readline
  end
  
  def getc
    io.getc
  end 
  
  def gets 
    readline
  end
end 
