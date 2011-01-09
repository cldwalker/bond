# RUBY_PLATFORM[/mswin|mingw|bccwin|wince/i]
class Bond::Ruby < Bond::Readline
  def self.readline_setup
    require 'rb-readline'
  rescue LoadError
    abort "Bond Error: rb-readline gem is required for this readline plugin" +
      " -> gem install rb-readline"
  end
end
