module Bond
  # Handles finding and executing the first mission that matches the input line. Once found, it calls the mission's action.
  class Agent
    # The array of missions that will be searched when a completion occurs.
    attr_reader :missions

    def initialize(options={}) #:nodoc:
      raise ArgumentError unless options[:readline_plugin].is_a?(Module)
      extend(options[:readline_plugin])
      @default_mission_action = options[:default_mission] if options[:default_mission]
      Mission.eval_binding = options[:eval_binding] if options[:eval_binding]
      Mission.default_search = options[:default_search] if options[:default_search]
      setup
      @missions = []
    end

    def complete(options={}, &block)
      if (mission = create_mission(options, &block)).is_a?(Mission)
        mission.place.is_a?(Integer) ? @missions.insert(mission.place - 1, mission).compact! : @missions << mission
        sort_last_missions
      end
      mission
    end

    def create_mission(options, &block) #:nodoc:
      Mission.create options.merge!(:action=>options[:action] || block)
    rescue InvalidMissionError
      "Invalid mission given. Mission needs an action and a condition."
    rescue
      "Mission setup failed with:\n#{$!}"
    end

    def recomplete(options={}, &block)
      if (mission = create_mission(options, &block)).is_a?(Mission)
        if (existing_mission = @missions.find {|e| e.unique_id == mission.unique_id })
          @missions[@missions.index(existing_mission)] = mission
          sort_last_missions
        else
          return "No existing mission found to recomplete."
        end
      end
      mission
    end

    def sort_last_missions #:nodoc:
      @missions.replace @missions.partition {|e| e.place != :last }.flatten
    end

    def reset #:nodoc:
      @missions = []
    end

    # This is where the action starts when a completion is initiated.
    def call(input)
      mission_input = line_buffer
      mission_input = $1 if mission_input !~ /#{Regexp.escape(input)}$/ && mission_input =~ /^(.*#{Regexp.escape(input)})/
      (mission = find_mission(mission_input)) ? mission.execute : default_mission.execute(input)
    rescue FailedExecutionError
      $stderr.puts "", $!.message
    rescue
      if Bond.config[:debug]
        p $!
        p $!.backtrace.slice(0,5)
      end
      default_mission.execute(input)
    end

    def spy(input)
      if (mission = find_mission(input))
        puts mission.spy_message, "Possible completions: #{mission.execute.inspect}",
          "Matches for #{mission.condition.inspect} are #{mission.matched.to_a.inspect}"
      else
        puts "Doesn't match a completion."
      end
    end

    def find_mission(input) #:nodoc:
      @missions.find {|mission| mission.matches?(input) }
    end

    # Default mission used by agent.
    def default_mission
      @default_mission ||= DefaultMission.new(:action=>@default_mission_action)
    end
  end
end