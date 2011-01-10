module Bond
  # Every time a completion is attempted, the Agent searches its missions for
  # the first one that matches the user input.  Using either the found mission
  # or Agent.default_mission, the Agent executes the mission's action.
  class Agent
    # The array of missions that will be searched when a completion occurs.
    attr_reader :missions
    # An agent's best friend a.k.a. the readline plugin.
    attr_reader :weapon

    def initialize(options={}) #@private
      setup_readline(options[:readline])
      @default_mission_action = options[:default_mission] if options[:default_mission]
      Mission.eval_binding = options[:eval_binding] if options[:eval_binding]
      Search.default_search = options[:default_search] || :normal
      @missions = []
    end

    # Creates a mission.
    def complete(options={}, &block)
      if (mission = create_mission(options, &block)).is_a?(Mission)
        mission.place.is_a?(Integer) ? @missions.insert(mission.place - 1, mission).compact! : @missions << mission
        sort_last_missions
      end
      mission
    end

    # Creates a mission and replaces the mission it matches if possible.
    def recomplete(options={}, &block)
      if (mission = create_mission(options, &block)).is_a?(Mission)
        if (existing_mission = @missions.find {|e| e.name == mission.name })
          @missions[@missions.index(existing_mission)] = mission
          sort_last_missions
        else
          return "No existing mission found to recomplete."
        end
      end
      mission
    end

    # This is where the action starts when a completion is initiated. Optional
    # line_buffer overrides line buffer from readline plugin.
    def call(input, line_buffer=nil)
      mission_input = line_buffer || @weapon.line_buffer
      mission_input = $1 if mission_input !~ /#{Regexp.escape(input)}$/ && mission_input =~ /^(.*#{Regexp.escape(input)})/
      (mission = find_mission(mission_input)) ? mission.execute : default_mission.execute(Input.new(input))
    rescue FailedMissionError => e
      completion_error(e.message, "Completion Info: #{e.mission.match_message}")
    rescue
      completion_error "Failed internally with '#{$!.message}'.",
        "Please report this issue with debug on: Bond.config[:debug] = true."
    end

    # Given a hypothetical user input, reports back what mission it would have
    # found and executed.
    def spy(input)
      if (mission = find_mission(input))
        puts mission.match_message, "Possible completions: #{mission.execute.inspect}",
          "Matches for #{mission.condition.inspect} are #{mission.matched.to_a.inspect}"
      else
        puts "Doesn't match a completion."
      end
    rescue FailedMissionError => e
      puts e.mission.match_message, e.message,
        "Matches for #{e.mission.condition.inspect} are #{e.mission.matched.to_a.inspect}"
    end

    def find_mission(input) #@private
      @missions.find {|mission| mission.matches?(input) }
    end

    # Default mission used by agent. An instance of DefaultMission.
    def default_mission
      @default_mission ||= DefaultMission.new(:action => @default_mission_action)
    end

    # Resets an agent's missions
    def reset
      @missions = []
    end

    protected
    def setup_readline(plugin)
      @weapon = plugin
      @weapon.setup(self)
    rescue
      $stderr.puts "Bond Error: Failed #{plugin.to_s[/[^:]+$/]} setup with '#{$!.message}'"
    end

    def create_mission(options, &block)
      Mission.create options.merge!(:action => options[:action] || block)
    rescue InvalidMissionError
      "Invalid #{$!.message} for completion with options: #{options.inspect}"
    rescue
      "Unexpected error while creating completion with options #{options.inspect} and message:\n#{$!}"
    end

    def sort_last_missions
      @missions.replace @missions.partition {|e| e.place != :last }.flatten
    end

    def completion_error(desc, message)
      arr = ["Bond Error: #{desc}", message]
      arr << "Stack Trace: #{$!.backtrace.inspect}" if Bond.config[:debug]
      arr
    end
  end
end
