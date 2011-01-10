require 'bond/m'
require 'bond/version'
require 'bond/readline'
require 'bond/readlines/rawline'
require 'bond/readlines/ruby'
require 'bond/readlines/jruby'
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

  # Creates a completion rule (Mission). A valid Mission consists of a condition and an action. A
  # condition is specified with one of the following options: :on, :object, :anywhere or :method(s). Each
  # of these options creates a different Mission class. An action is either the method's block or :action.
  # An action takes what the user has typed (Input) and returns an array of possible completions. Bond
  # searches these completions and returns matching completions. This searching behavior can be configured
  # or turned off per mission with :search. If turned off, the action must also handle searching.
  #
  # ==== Examples:
  #  Bond.complete(:method => 'shoot') {|input| %w{to kill} }
  #  Bond.complete(:on => /^((([a-z][^:.\(]*)+):)+/, :search => false) {|input| Object.constants.grep(/#{input.matched[1]}/) }
  #  Bond.complete(:object => ActiveRecord::Base, :search => :underscore, :place => :last)
  #  Bond.complete(:method => 'you', :search => proc {|input, list| list.grep(/#{input}/i)} ) {|input| %w{Only Live Twice} }
  #  Bond.complete(:method => 'system', :action => :shell_commands)
  #
  # @param [Hash] options When using :method(s) or :object, some hash keys may have different behavior. See
  #   Bond.complete sections of {MethodMission} and {ObjectMission} respectively.
  # @option options [Regexp] :on Matches the full line of input to create a {Mission} object.
  # @option options [String] :method An instance (Class#method) or class method (Class.method). Creates
  #   {MethodMission} object. A method's class can be set by :class or detected automatically if '#' or '.' is
  #   present. If no class is detected, 'Kernel#' is assumed.
  # @option options [Array<String>] :methods Instance or class method(s) in the format of :method. Creates
  #   {MethodMission} objects.
  # @option options [String] :class Optionally used with :method or :methods to represent module/class.
  #   Must end in '#' or '.' to indicate instance/class method. Suggested for use with :methods.
  # @option options [String] :object Module or class of an object whose methods are completed. Creates
  #   {ObjectMission} object.
  # @option options [String] :anywhere String representing a regular expression to match a mission. Creates
  #   {AnywhereMission} object.
  # @option options [String] :prefix Optional string to prefix :anywhere.
  # @option options [Symbol,false] :search Determines how completions are searched. Defaults to
  #   Search.default_search. If false, search is turned off and assumed to be done in the action.
  #   Possible symbols are :anywhere, :ignore_case, :underscore, :normal, :files and :modules.
  #   See {Search} for more info.
  # @option options [String,Symbol] :action Rc method name that takes an Input and returns possible completions.
  #   See {MethodMission} for specific behavior with :method(s).
  # @option options [Integer,:last] :place Indicates where a mission is inserted amongst existing
  #   missions. If the symbol :last, places the mission at the end regardless of missions defined
  #   after it. Multiple declarations of :last are kept last in the order they are defined.
  # @option options [Symbol,String] :name Unique id for a mission which can be passed by
  #   Bond.recomplete to identify and replace the mission.
  def complete(options={}, &block); M.complete(options, &block); end

  # Redefines an existing completion mission to have a different action. The condition can only be varied if :name is
  # used to identify and replace a mission. Takes same options as {#complete}.
  # ==== Example:
  #   Bond.recomplete(:on => /man/, :name => :count) { %w{4 5 6}}
  def recomplete(options={}, &block); M.recomplete(options, &block); end

  # Reports what completion mission matches for a given input. Helpful for debugging missions.
  # ==== Example:
  #   >> Bond.spy "shoot oct"
  #   Matches completion mission for method matching "shoot".
  #   Possible completions: ["octopussy"]
  def spy(*args); M.spy(*args); end

  # @return [Hash] Global config
  def config; M.config; end

  # Starts Bond with a default set of completions that replace and improve irb's completion. Loads completions
  # in this order: lib/bond/completion.rb, lib/bond/completions/*.rb and the following optional completions:
  # completions from :gems, ~/.bondrc, ~/.bond/completions/*.rb and from block. See
  # {Rc} for the DSL to use in completion files and in the block.
  #
  # ==== Examples:
  #   Bond.start :gems => %w{hirb}
  #   Bond.start(:default_search => :ignore_case) do
  #     complete(:method => "Object#respond_to?") {|e| e.object.methods }
  #   end
  #
  # @param [Hash] options Sets global keys in {#config}, some which specify what completions to load.
  # @option options [Array<String>] :gems Gems which have their completions loaded from
  #   @gem_source/lib/bond/completions/*.rb. If gem is a plugin gem i.e. ripl-plugin, completion will be loaded
  #   from @gem_source/lib/ripl/completions/plugin.rb.
  # @option options [Module, Symbol] :readline (Bond::Readline) Specifies a Bond readline plugin.
  #   A symbol points to a capitalized Bond constant i.e. :ruby -> Bond::Ruby.
  #   Available plugins are Bond::Readline, Bond::Ruby, Bond::Jruby and Bond::Rawline.
  # @option options [Proc] :default_mission (DefaultMission) Sets default completion to use when no missions match.
  #  See {Agent#default_mission}.
  # @option options [Symbol] :default_search (:underscore) Name of a *_search method in Rc to use as the default
  #   search in completions. See {#complete}'s :search option for valid values.
  # @option options [Binding, Proc] :eval_binding (TOPLEVEL_BINDING) Binding to use when evaluating objects in
  #   ObjectMission and MethodMission. When in irb, defaults to irb's current binding. When proc,
  #   binding is evaluated each time by calling proc.
  # @option options [Boolean] :debug (false) Shows the stacktrace when autocompletion fails and raises exceptions
  #   in Rc.eval.
  # @option options [Boolean] :eval_debug (false) Raises eval errors occuring when finding a matching completion.
  #   Useful to debug an incorrect completion
  # @option options [Boolean] :bare (false) Doesn't load default ruby completions and completions in
  #   ~/.bond*. Useful for non-ruby completions
  def start(options={}, &block); M.start(options, &block); end

  # Restarts completions with given options, ensuring to delete current completions.
  # Takes same options as Bond#start.
  def restart(options={}, &block); M.restart(options, &block); end

  # Indicates if Bond has already started
  def started?; M.started?; end

  # Loads completions for gems that ship with them under lib/bond/completions/, relative to the gem's base directory.
  def load_gems(*gems); M.load_gems(*gems); end

  # An Agent who saves all Bond.complete missions and executes the correct one when a completion is called.
  def agent; M.agent; end

  # Lists all methods that have argument completion.
  def list_methods; MethodMission.all_methods; end
end
