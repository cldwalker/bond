require 'bond/m'
require 'bond/version'
require 'bond/readline'
require 'bond/rawline'
require 'bond/agent'
require 'bond/search'
require 'bond/input'
require 'bond/actions'
require 'bond/rc'
require 'bond/mission'
require 'bond/missions/default_mission'
require 'bond/missions/method_mission'
require 'bond/missions/object_mission'
require 'bond/missions/anywhere_mission'
require 'bond/missions/operator_method_mission'

# Bond allows easy handling and creation of completion missions/rules with Bond.complete. When Bond is asked to autocomplete, Bond looks
# up the completion missions in the order they were defined and picks the first one that matches what the user has typed.
# Bond::Agent handles finding and executing the correct completion mission. 
# Some pointers on using/understanding Bond:
# * Bond can be configured to work outside of irb and readline. See Bond::M.config
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
  #             of a line. Creates a Bond::MethodMission object. If given a string, the match has to be exact.
  #             Since this is used mainly for argument completion, completions can have an optional quote in front of them.
  # [*:object*] Matches the given string or regular expression to the ancestor of the current object being completed. Creates a 
  #             Bond::ObjectMission object. Access to the current object is passed to the completion proc as the input's
  #             attribute :object. If no action is given, this completion type defaults to all methods the object responds to.
  # [*:anywhere*] Matches the given regular expression to create a Bond::AnywhereMission object. Regex must end in '$' and
  #               must encompass the whole regular expression in '()'.
  # [*:search*] Given a symbol or false, determines how completions are searched to match what the user has typed. Defaults to
  #             traditional searching i.e. looking at the beginning of a string for possible matches. If false, search is turned off and
  #             assumed to be done in the action block. Possible symbols are :anywhere, :ignore_case and :underscore. See Bond::Search for
  #             more info about them.
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

  def spy(*args); M.spy(*args); end
  def agent(*args); M.agent(*args);end
  def config; M.config; end
  def reset; M.reset; end
  def load(*args, &block); M.load(*args, &block); end
end