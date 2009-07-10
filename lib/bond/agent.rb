module Bond
  class Agent
    def initialize(options={})
      raise ArgumentError unless options[:readline_plugin]
      extend(options[:readline_plugin])
      setup
      @missions = []
    end

    def complete(options={}, &block)
      @missions << Mission.new(options.merge(:action=>block))
    end

    def call(input)
      mission, new_input, match = find_mission(input)
      mission.call(new_input, match)
    rescue
      p $!
      p $!.backtrace.slice(0,5)
      default_mission.call(input)
    end

    def find_mission(input)
      if @missions.any? {|e| e.command }
        all_input = line_buffer
        match = all_input.match /^\s*(\S+)\s*(.*)$/
        if (command = match[1])
          @missions.each do |mission|
            return [mission, match[2], //] if mission.command == command
          end
        end
      end
      input = all_input[/(\S+)\s*$/,1]
      @missions.each do |mission|
        if mission.pattern && (match = input.match(mission.pattern))
          return [mission, input, match]
        end
      end
      raise "calling default mission"
    end

    def default_mission
      Object.const_defined?(:IRB) ? Mission.new(:action=>IRB::InputCompletor::CompletionProc) :
        lambda {|e| [] }
    end
  end
end