module Bond
  # Takes demands from the real world (user) and translates them to missions to be given to an Agent.
  module M
    extend self

    # See Bond.complete
    def complete(options={}, &block)
      if (result = agent.complete(options, &block)).is_a?(String)
        $stderr.puts result
        false
      else
        true
      end
    end

    # See Bond.recomplete
    def recomplete(options={}, &block)
      if (result = agent.recomplete(options, &block)).is_a?(String)
        $stderr.puts result
        false
      else
        true
      end
    end

    # See Bond.agent
    def agent
      @agent ||= Agent.new(config)
    end

    # See Bond.config
    def config
      @config ||= {:readline_plugin=>Bond::Readline, :debug=>false, :default_search=>:underscore}
    end

    # Resets M by deleting all missions.
    def reset
      MethodMission.reset
      @agent = nil
    end

    # See Bond.spy
    def spy(input)
      agent.spy(input)
    end

    # Validates and sets values in M.config.
    def debrief(options={})
      config.merge! options
      plugin_methods = %w{setup line_buffer}
      unless config[:readline_plugin].is_a?(Module) &&
        plugin_methods.all? {|e| config[:readline_plugin].instance_methods.map {|f| f.to_s}.include?(e)}
        $stderr.puts "Invalid readline plugin set. Try again."
      end
    end

    # See Bond.start
    def start(options={}, &block)
      debrief options
      load_completions
      Rc.module_eval(&block) if block
      true
    end

    def load_completions #:nodoc:
      load_file File.join(File.dirname(__FILE__), 'completion.rb')
      load_file(File.join(home,'.bondrc')) if File.exists?(File.join(home, '.bondrc'))
      [File.dirname(__FILE__), File.join(home, '.bond')].each do |base_dir|
        load_dir(base_dir)
      end
    end

    # Loads a completion file in Rc namespace.
    def load_file(file)
      Rc.module_eval File.read(file)
    rescue Exception => e
      puts "Error: File '#{file}' failed to load:", e.message
    end

    def load_dir(base_dir) #:nodoc:
      if File.exists?(dir = File.join(base_dir, 'completions'))
        Dir[dir + '/*.rb'].each {|file| load_file(file) }
      end
    end

    # Find a user's home in a cross-platform way
    def home
      ['HOME', 'USERPROFILE'].each {|e| return ENV[e] if ENV[e] }
      return "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}" if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      File.expand_path("~")
    rescue
      File::ALT_SEPARATOR ? "C:/" : "/"
    end
  end
end