# A pure ruby readline which requires {rb-readline}[https://github.com/luislavena/rb-readline].
class Bond::Ruby < Bond::Readline
  def self.readline_setup
    require 'readline'
  rescue LoadError
    abort "Bond Error: rb-readline gem is required for this readline plugin" +
      " -> gem install rb-readline"
  end
end
