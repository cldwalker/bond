current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'bond/readline'
require 'bond/rawline'
require 'bond/agent'
require 'bond/search'
require 'bond/mission'
require 'bond/missions/default_mission'
require 'bond/missions/method_mission'
require 'bond/missions/object_mission'

# Bond allows easy handling and creation of completion missions/rules with Bond.complete. When Bond is asked to autocomplete, Bond looks
# up the completion missions in the order they were defined and picks the first one that matches what the user has typed.
# Bond::Agent handles finding and executing the correct completion mission. 
# Some pointers on using/understanding Bond:
# * Bond can work outside of irb and readline when debriefed with Bond.debrief. This should be called before any Bond.complete calls.
# * Bond doesn't take over completion until an explicit Bond.complete is called.
# * Order of completion missions matters. The order they're defined in is the order Bond searches
#   when looking for a matching completion. This means that you should probably declare general
#   completions at the end.
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
  # [:on] Matches the given regular expression with the full line of input.  Creates a Bond::Mission object.
  #       Access to the matches in the regular expression are passed to the completion proc as the input's attribute :matched.
  # [:method] Matches the given string or regular expression with any methods (or any non-whitespace string) that start the beginning
  #           of a line. Creates a Bond::Missions:MethodMission object. If given a string, the match has to be exact.
  #           Since this is used mainly for argument completion, completions can have an optional quote in front of them.
  # [:object] Matches the given a string or regular expression to the ancestor of the current object being completed. Creates a 
  #           Bond::Missions::ObjectMission object. Access to the current object is passed to the completion proc as the input's
  #           attribute :object. If no action is given, this completion type defaults to all methods the object responds to.
  # [:search] Given a symbol, proc or false, determines how completions are searched to match what the user has typed. Defaults to
  #           traditional searching i.e. looking at the beginning of a string for possible matches. If false, search is turned off and
  #           assumed to be done in the action block. Possible symbols are :anywhere, :ignore_case and :underscore. See Bond::Search for
  #           more info about them. A proc is given two arguments: the input string and an array of possible completions.
  #
  # ==== Examples:
  #  Bond.complete(:method=>'shoot') {|input| %w{to kill} }
  #  Bond.complete(:on=>/^((([a-z][^:.\(]*)+):)+/, :search=>false) {|input| Object.constants.grep(/#{input.matched[1]}/) }
  #  Bond.complete(:object=>ActiveRecord::Base, :search=>:underscore)
  #  Bond.complete(:object=>ActiveRecord::Base) {|input| input.object.class.instance_methods(false) }
  #  Bond.complete(:method=>'you', :search=>proc {|input, list| list.grep(/#{input}/i)} ) {|input| %w{Only Live Twice} }
  def complete(options={}, &block)
    agent.complete(options, &block)
    true
  rescue InvalidMissionError
    $stderr.puts "Invalid mission given. Mission needs an action and a condition."
    false
  rescue
    $stderr.puts "Mission setup failed with:", $!
    false
  end

  # Resets Bond so that next time Bond.complete is called, a new set of completion missions are created. This does not
  # change current completion behavior.
  def reset
    @agent = nil
  end

  # Debriefs Bond to set global defaults. Call before defining completions.
  # ==== Options:
  # [:readline_plugin] Specifies a Bond plugin to interface with a Readline-like library. Available plugins are Bond::Readline and Bond::Rawline.
  #                    Defaults to Bond::Readline. Note that a plugin doesn't imply use with irb. Irb is joined to the hip with Readline.
  # [:default_mission] A proc to be used as the default completion proc when no completions match or one fails. When in irb with completion
  #                    enabled, uses irb completion. Otherwise defaults to a proc with an empty completion list.
  # [:eval_binding] Specifies a binding to be used with Bond::Missions::ObjectMission. When in irb, defaults to irb's main binding. Otherwise
  #                 defaults to TOPLEVEL_BINDING.
  # [:debug]  Boolean to print unexpected errors when autocompletion fails. Default is false.
  def debrief(options={})
    config.merge! options
    plugin_methods = %w{setup line_buffer}
    unless config[:readline_plugin].is_a?(Module) &&
      plugin_methods.all? {|e| config[:readline_plugin].instance_methods.map {|f| f.to_s}.include?(e)}
      $stderr.puts "Invalid readline plugin set. Try again."
    end
  end

  # Reports what completion mission and possible completions would happen for a given input. Helpful for debugging
  # your completion missions.
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