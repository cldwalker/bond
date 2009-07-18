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
      options[:action] ||= block
      @missions << Mission.create(options.merge(:eval_binding=>@eval_binding))
    end

    # This is where the action starts when a completion is initiated.
    def call(input)
      # Use line_buffer instead of input since it's more info
      (mission = find_mission(line_buffer)) ? mission.execute : default_mission.execute(input)
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
        if mission.is_a?(Missions::ObjectMission)
          puts "Matches completion mission for object with an ancestor matching #{mission.object_condition.inspect}."
        elsif mission.is_a?(Missions::MethodMission)
          puts "Matches completion mission for method matching #{mission.method_condition.inspect}."
        else
          puts "Matches completion mission with condition #{mission.condition.inspect}."
        end
        puts "Possible completions: #{mission.execute.inspect}"
      else
        puts "Doesn't match a completion mission."
      end
    end

    def find_mission(input) #:nodoc:
      @missions.find {|mission| mission.matches?(input) }
    end

    # Default mission used by agent.
    def default_mission
      @default_mission ||= Missions::DefaultMission.new(:action=>@default_mission_action)
    end
  end
end