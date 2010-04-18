require 'bond/version'
require 'bond/readline'
require 'bond/rawline'
require 'bond/agent'
require 'bond/search'
require 'bond/actions'
require 'bond/rc'
require 'bond/mission'
require 'bond/missions/default_mission'
require 'bond/missions/method_mission'
require 'bond/missions/object_mission'
require 'bond/missions/anywhere_mission'
require 'bond/missions/object_method_mission'

# Bond allows easy handling and creation of completion missions/rules with Bond.complete. When Bond is asked to autocomplete, Bond looks
# up the completion missions in the order they were defined and picks the first one that matches what the user has typed.
# Bond::Agent handles finding and executing the correct completion mission. 
# Some pointers on using/understanding Bond:
# * Bond can work outside of irb and readline when debriefed with Bond.debrief. This should be called before any Bond.complete calls.
# * Bond doesn't take over completion until an explicit Bond.complete is called.
# * Order of completion missions matters. The order they're defined in is the order Bond searches
#   when looking for a matching completion. This means that more specific completions like method and object completions should come
#   before more general ones. You can tweak completion placement by passing :place to Bond.complete.
# * If no completion missions match, then Bond falls back on a default mission. If using irb and irb/completion
#   this falls back on irb's completion. Otherwise an empty completion list is returned.
module Bond
  extend self

  # Defines a completion mission aka a Bond::Mission. A valid mission consists of a condition and an action block.
  # A condition is specified with one of the following options: :on, :object or :method. Depending on the condition option, a
  # different type of Bond::Mission is created. Action blocks are given what the user has typed and should a return a list of possible
  # completions. By default Bond searches possible completions to only return the ones that match what has been typed. This searching
  # behavior can be customized with the :search option.
  # ====Options:
  # [*:on*] Matches the given regular expression with the full line of input.  Creates a Bond::Mission object.
  #         Access to the matches in the regular expression are passed to the completion proc as the input's attribute :matched.
  # [*:method*] Matches the given string or regular expression with any methods (or any non-whitespace string) that start the beginning
  #             of a line. Creates a Bond::Missions:MethodMission object. If given a string, the match has to be exact.
  #             Since this is used mainly for argument completion, completions can have an optional quote in front of them.
  # [*:object*] Matches the given string or regular expression to the ancestor of the current object being completed. Creates a 
  #             Bond::Missions::ObjectMission object. Access to the current object is passed to the completion proc as the input's
  #             attribute :object. If no action is given, this completion type defaults to all methods the object responds to.
  # [*:anywhere*] Matches the given regular expression to create a Bond::Missions::AnywhereMission object. Regex must end in '$' and
  #               must encompass the whole regular expression in '()'.
  # [*:search*] Given a symbol, proc or false, determines how completions are searched to match what the user has typed. Defaults to
  #             traditional searching i.e. looking at the beginning of a string for possible matches. If false, search is turned off and
  #             assumed to be done in the action block. Possible symbols are :anywhere, :ignore_case and :underscore. See Bond::Search for
  #             more info about them. A proc is given two arguments: the input string and an array of possible completions.
  # [*:action*] Symbol referencing an instance method in Actions to be the action block.
  # [*:place*] Given a symbol or number, controls where this completion is placed in relation to existing ones. If a number, the
  #            completion is placed at that number. If the symbol :last, the completion is placed at the end regardless of completions
  #            defined after it. Use this symbol as a way of anchoring completions you want to remain at the end. Multiple declarations
  #            of :last are kept last in the order they are defined.
  #
  # ==== Examples:
  #  Bond.complete(:method=>'shoot') {|input| %w{to kill} }
  #  Bond.complete(:on=>/^((([a-z][^:.\(]*)+):)+/, :search=>false) {|input| Object.constants.grep(/#{input.matched[1]}/) }
  #  Bond.complete(:object=>ActiveRecord::Base, :search=>:underscore, :place=>:last)
  #  Bond.complete(:object=>ActiveRecord::Base) {|input| input.object.class.instance_methods(false) }
  #  Bond.complete(:method=>'you', :search=>proc {|input, list| list.grep(/#{input}/i)} ) {|input| %w{Only Live Twice} }
  #  Bond.complete(:method=>'system', :action=>:shell_commands)
  def complete(options={}, &block)
    if (result = agent.complete(options, &block)).is_a?(String)
      $stderr.puts result
      $stderr.puts "Mission options: #{options.inspect}" if config[:debug]
      false
    else
      true
    end
  end

  # Redefines an existing completion mission. Takes same options as Bond.complete. This is useful when wanting to override existing
  # completions or when wanting to toggle between multiple definitions or modes of a completion.
  def recomplete(options={}, &block)
    if (result = agent.recomplete(options, &block)).is_a?(String)
      $stderr.puts result
      $stderr.puts "Mission options: #{options.inspect}" if config[:debug]
      false
    else
      true
    end
  end

  # Resets Bond so that next time Bond.complete is called, a new set of completion missions are created. This does not
  # change current completion behavior.
  def reset
    @agent = nil
  end

  # Debriefs Bond to set global defaults. Call before defining completions.
  # ==== Options:
  # [*:readline_plugin*] Specifies a Bond plugin to interface with a Readline-like library. Available plugins are Bond::Readline
  #                      and Bond::Rawline. Defaults to Bond::Readline. Note that a plugin doesn't imply use with irb. Irb is
  #                      joined to the hip with Readline.
  # [*:default_mission*] A proc to be used as the default completion proc when no completions match or one fails. When in irb
  #                      with completion enabled, uses irb completion. Otherwise defaults to a proc with an empty completion list.
  # [*:default_search*] A symbol or proc to be used as the default search in completions. See Bond.complete's :search option for valid symbols.
  # [*:eval_binding*] Specifies a binding to be used with Bond::Missions::ObjectMission. When in irb, defaults to irb's main
  #                   binding. Otherwise defaults to TOPLEVEL_BINDING.
  # [*:debug*]  Boolean to print unexpected errors when autocompletion fails. Default is false.
  #
  # ==== Example:
  #   Bond.debrief :default_search=>:underscore, :default_mission=>:default
  def debrief(options={})
    config.merge! options
    plugin_methods = %w{setup line_buffer}
    unless config[:readline_plugin].is_a?(Module) &&
      plugin_methods.all? {|e| config[:readline_plugin].instance_methods.map {|f| f.to_s}.include?(e)}
      $stderr.puts "Invalid readline plugin set. Try again."
    end
  end

  # Loads bond/completion, optional ~/.bondrc and optional block.
  # See Rc for syntax in ~/.bondrc
  def load(&block)
    require 'bond/completion'
    if File.exists?(File.join(home, '.bondrc'))
      Rc.module_eval File.read(File.join(home, '.bondrc'))
    end
    Rc.instance_eval(&block) if block
    true
  end

  # Find a user's home in a cross-platform way
  def home
    ['HOME', 'USERPROFILE'].each {|e| return ENV[e] if ENV[e] }
    return "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
    File.expand_path("~")
  rescue
    File::ALT_SEPARATOR ? "C:/" : "/"
  end

  # Reports what completion mission and possible completions would happen for a given input. Helpful for debugging
  # your completion missions.
  # ==== Example:
  #   >> Bond.spy "shoot oct"
  #   Matches completion mission for method matching "shoot".
  #   Possible completions: ["octopussy"]
  def spy(input)
    agent.spy(input)
  end

  def agent #:nodoc:
    @agent ||= Agent.new(config)
  end

  def config #:nodoc:
    @config ||= {:readline_plugin=>Bond::Readline, :debug=>false}
  end
end