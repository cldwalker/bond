module Bond
  # Handles finding and executing the first mission that matches the input line. Once found, it calls the mission's action.
  class Agent
    # The array of missions that will be searched when a completion occurs.
    attr_reader :missions

    def initialize(options={}) #:nodoc:
      raise ArgumentError unless options[:readline_plugin].is_a?(Module)
      extend(options[:readline_plugin])
      @default_mission_action = options[:default_mission] if options[:default_mission]
      @eval_binding = options[:eval_binding] if options[:eval_binding]
      setup
      @missions = []
    end

    def complete(options={}, &block) #:nodoc:
      @missions << Mission.create(options.merge(:action=>block, :eval_binding=>@eval_binding))
    end

    # This is where the action starts when a completion is initiated.
    def call(input)
      (mission = find_mission(input)) ? mission.execute : default_mission.execute(input)
    rescue FailedExecutionError
      $stderr.puts "", $!.message
    rescue
      p $!
      p $!.backtrace.slice(0,5)
      default_mission.execute(input)
    end

    # No need to use what's passed to the completion proc when we can get the full line.
    def find_mission(input) #:nodoc:
      all_input = line_buffer
      @missions.find {|mission| mission.matches?(all_input) }
    end

    # Default mission used by agent.
    def default_mission
      @default_mission ||= Missions::DefaultMission.new(:action=>@default_mission_action)
    end
  end
end