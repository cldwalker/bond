module Bond
  class Agent
    attr_reader :missions

    def initialize(options={})
      raise ArgumentError unless options[:readline_plugin].is_a?(Module)
      extend(options[:readline_plugin])
      @default_mission_action = options[:default_mission] if options[:default_mission]
      @eval_binding = options[:eval_binding] if options[:eval_binding]
      setup
      @missions = []
    end

    def complete(options={}, &block)
      @missions << Mission.new(options.merge(:action=>block, :eval_binding=>eval_binding))
    end

    def call(input)
      (mission = find_mission(input)) ? mission.execute : default_mission.execute(input)
    rescue FailedExecutionError
      $stderr.puts "", $!.message
    rescue
      p $!
      p $!.backtrace.slice(0,5)
      default_mission.execute(input)
    end

    def find_mission(input)
      all_input = line_buffer
      @missions.find {|mission| mission.matches?(all_input) }
    end

    def default_mission
      @default_mission ||= Mission.new(:action=>default_mission_action, :default=>true)
    end

    def default_mission_action
      @default_mission_action ||= Object.const_defined?(:IRB) ? IRB::InputCompletor::CompletionProc : lambda {|e| [] }
    end

    def eval_binding
      @eval_binding ||= Object.const_defined?(:IRB) ? IRB.CurrentContext.workspace.binding : ::TOPLEVEL_BINDING
    end
  end
end