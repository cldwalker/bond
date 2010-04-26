require 'bond/m'
require 'bond/version'
require 'bond/readline'
require 'bond/rawline'
require 'bond/agent'
require 'bond/search'
require 'bond/input'
require 'bond/rc'
require 'bond/mission'
require 'bond/missions/default_mission'
require 'bond/missions/method_mission'
require 'bond/missions/object_mission'
require 'bond/missions/anywhere_mission'
require 'bond/missions/operator_method_mission'

# Bond allows easy handling and creation of completion missions/rules with Bond.complete. When Bond is asked to autocomplete, Bond looks
# up the completion missions in the order they were defined and picks the first one that matches what the user has typed.
# Agent handles finding and executing the correct completion mission.
# Some pointers on using/understanding Bond:
# * Bond can be configured to work outside of irb and readline. See M.config
# * Order of completion missions matters. The order they're defined in is the order Bond searches
#   when looking for a matching completion. This means that more specific completions like method and object completions should come
#   before more general ones. You can tweak completion placement by passing :place to Bond.complete.
# * If no completion missions match, then Bond falls back on a default mission. If using irb and irb/completion
#   this falls back on irb's completion. Otherwise an empty completion list is returned.
module Bond
  extend self

  # Defines a completion rule (Mission). A valid Mission consists of a condition and an action block.
  # A condition is specified with one of the following options: :on, :object, :anywhere or :method(s).
  # Depending on the condition option, a different type of Mission is created. An action block is either
  # the method's block or an existing action specified with :action.
  # An action block is given
  # what the user has typed (Input) and must return an array of possible completions. Bond searches these
  # completions to return ones that match the input. This searching behavior can be customized or
  # turned off per completion.
  # ====Options:
  # [*:on*] Regular expression which matches the full line of input to create a Mission object.
  # [*:method*, *:methods*, *:class*] See MethodMission
  # [*:object*] String representing a module/class which is an ancestor of an object whose methods are
  #             being completed. ObjectMission object. Access to the current object is passed to the
  #             completion proc as the input's attribute :object. If no action is given, this completion
  #             type defaults to all methods the object responds to.
  # [*:anywhere*] A string representing a regular expression which can match anywhere. Creates an
  #               AnywhereMission object.
  # [*:search*] A symbol or false which determines how completions are searched. Defaults to :default_search
  #             value in Bond.config. If false, search is turned off and assumed to be done in the action
  #             block. Possible symbols are :anywhere, :ignore_case, :underscore, :default. See Search.
  # [*:action*] Symbol referencing an Rc method to be the action block. See MethodMission for specific
  #             behavior with :method.
  # [*:place*] A number or :last which indicates where a mission is inserted amongst existing missions. If
  #            the symbol :last, places the mission at the end regardless of missions defined after it.
  #            This option is useful for controlling order of missions, which is important to ensure they
  #            executed.
  # [*:name*]
  # Use this symbol as a way of anchoring completions you want to remain at the end. Multiple declarations
  #            of :last are kept last in the order they are defined.
  #
  # ==== Examples:
  #  Bond.complete(:method=>'shoot') {|input| %w{to kill} }
  #  Bond.complete(:on=>/^((([a-z][^:.\(]*)+):)+/, :search=>false) {|input| Object.constants.grep(/#{input.matched[1]}/) }
  #  Bond.complete(:object=>ActiveRecord::Base, :search=>:underscore, :place=>:last)
  #  Bond.complete(:object=>ActiveRecord::Base) {|input| input.object.class.instance_methods(false) }
  #  Bond.complete(:method=>'you', :search=>proc {|input, list| list.grep(/#{input}/i)} ) {|input| %w{Only Live Twice} }
  #  Bond.complete(:method=>'system', :action=>:shell_commands)
  def complete(*args, &block); M.complete(*args, &block); end

  # Redefines an existing completion mission. Takes same options as Bond.complete. This method should
  # be used to override existing completions or to toggle between different modes/actions of a mission.
  def recomplete(*args, &block); M.recomplete(*args, &block); end

  # Reports what completion mission and possible completions would happen for a given input. Helpful for
  # debugging your completion missions.
  # ==== Example:
  #   >> Bond.spy "shoot oct"
  #   Matches completion mission for method matching "shoot".
  #   Possible completions: ["octopussy"]
  def spy(*args); M.spy(*args); end

  # Global config with the following keys
  # ==== Keys:
  # [*:readline_plugin*] Specifies a Bond plugin to interface with a Readline-like library. Available
  #                      plugins are Readline and Rawline. Defaults to Readline.
  # [*:default_mission*] A proc to be used as the default completion proc when no completions match or one fails. When in irb
  #                      with completion enabled, uses irb completion. Otherwise defaults to a proc with an empty completion list.
  # [*:default_search*] A symbol referencing an Rc method to use as the default search in completions.
  #                     See Bond.complete's :search option for valid symbols.
  # [*:eval_binding*] Specifies a binding to use when evaluating objects in ObjectMission and MethodMission.
  #                   When in irb, defaults to irb's current binding. Otherwise defaults to TOPLEVEL_BINDING.
  # [*:debug*]  Boolean to show the stacktrace when autocompletion fails. Default is false.
  def config; M.config; end

  # Loads bond/completion, optional ~/.bondrc, plugins in lib/bond/completions/ and
  # ~/.bond/completions/ and optional block.
  # See Rc for syntax to use in ~/.bondrc and plugins.
  # See M.config for valid options.
  def start(*args, &block); M.start(*args, &block); end

  # The agent handling all the completion missions.
  def agent(*args); M.agent(*args);end
end