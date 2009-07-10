module Bond
  class Agent
    Defaultbreakchars = " \t\n\"\\'`><=;|&{("

    def initialize(options={})
      @missions = []
      Readline.completion_append_character = nil
      if Readline.respond_to?("basic_word_break_characters=")
        Readline.basic_word_break_characters = Defaultbreakchars
      end
      Readline.completion_proc = self
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
        all_input = Readline.line_buffer
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
      Mission.new :action=>IRB::InputCompletor::CompletionProc
    end
  end
end