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

module Bond
  extend self

  # Defines a completion rule (Mission). A valid Mission consists of a condition and an action. A
  # condition is specified with one of the following options: :on, :object, :anywhere or :method(s). Each
  # of these options creates a different Mission class. An action is either this method's block or :action.
  # An action takes what the user has typed (Input) and returns an array of possible completions. Bond
  # searches these completions and returns matching completions. This searching behavior can be configured
  # or turned off per mission with :search. If turned off, the action must also handle searching.
  # ====Options:
  # [*:on*] Regular expression which matches the full line of input to create a Mission object.
  # [*:method*, *:methods*, *:class*] See MethodMission.
  # [*:anywhere*, *:prefix*] See AnywhereMission.
  # [*:object*] See ObjectMission.
  # [*:search*] A symbol or false which determines how completions are searched. Defaults to :default_search
  #             value in Bond.config. If false, search is turned off and assumed to be done in the action.
  #             Possible symbols are :anywhere, :ignore_case, :underscore, :default. See Search for more.
  # [*:action*] Rc method name that takes an Input and returns possible completions. See MethodMission for
  #             specific behavior with :method(s).
  # [*:place*] A number or :last which indicates where a mission is inserted amongst existing missions.
  #            If the symbol :last, places the mission at the end regardless of missions defined after
  #            it. Multiple declarations of :last are kept last in the order they are defined.
  # [*:name*] A symbol or string that serves a unique id for a mission. This unique id can be passed by
  #           Bond.recomplete to identify and replace the mission.
  # ==== Examples:
  #  Bond.complete(:method=>'shoot') {|input| %w{to kill} }
  #  Bond.complete(:on=>/^((([a-z][^:.\(]*)+):)+/, :search=>false) {|input| Object.constants.grep(/#{input.matched[1]}/) }
  #  Bond.complete(:object=>ActiveRecord::Base, :search=>:underscore, :place=>:last)
  #  Bond.complete(:method=>'you', :search=>proc {|input, list| list.grep(/#{input}/i)} ) {|input| %w{Only Live Twice} }
  #  Bond.complete(:method=>'system', :action=>:shell_commands)
  def complete(options={}, &block); M.complete(options, &block); end

  # Redefines an existing completion mission to have a different action. The condition can only be varied if :name is
  # used to identify and replace a mission. Takes same options as Bond.complete.
  # ==== Example:
  #   Bond.recomplete(:on=>/man/, :name=>:count) { %w{4 5 6}}
  def recomplete(options={}, &block); M.recomplete(options, &block); end

  # Reports what completion mission matches for a given input. Helpful for debugging missions.
  # ==== Example:
  #   >> Bond.spy "shoot oct"
  #   Matches completion mission for method matching "shoot".
  #   Possible completions: ["octopussy"]
  def spy(*args); M.spy(*args); end

  # Global config with the following keys:
  # [*:readline_plugin*] Specifies a Bond plugin to interface with a Readline-like library. Available
  #                      plugins are Readline and Rawline. Defaults to Readline.
  # [*:default_mission*] A proc or name of an Rc method to use as the default completion when no
  #                      missions match.
  # [*:default_search*] Name of a *_search method in Rc to use as the default search in completions.
  #                     Default is :underscore. See Bond.complete's :search option for valid values.
  # [*:eval_binding*] Specifies a binding to use when evaluating objects in ObjectMission and MethodMission.
  #                   When in irb, defaults to irb's current binding. Otherwise defaults to TOPLEVEL_BINDING.
  # [*:debug*]  Boolean to show the stacktrace when autocompletion fails and raise exceptions in Rc.eval.
  #             Default is false.
  def config; M.config; end

  # Starts Bond with a default set of completions that replace and improve irb's completion. Loads completion
  # files in the following order: lib/bond/completion.rb, optional ~/.bondrc, lib/bond/completions/*.rb,
  # optional ~/.bond/completions/*.rb and optional block. See Rc for the DSL to use in completion files and
  # in the block. See Bond.config for valid options.
  # ==== Example:
  #   Bond.start(:default_search=>:ignore_case) do
  #     complete(:method=>"Object#respond_to?") {|e| e.object.methods }
  #   end
  def start(options={}, &block); M.start(options, &block); end

  # An Agent who saves all Bond.complete missions and executes the correct one when a completion is called.
  def agent; M.agent; end

  # Lists all methods that have argument completion.
  def list_methods; MethodMission.all_methods; end
end