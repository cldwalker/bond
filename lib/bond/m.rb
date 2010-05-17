module Bond
  # Takes international quagmires (a user's completion setup) and passes them on as missions to an Agent.
  module M
    extend self

    # See Bond.complete
    def complete(options={}, &block)
      if (result = agent.complete(options, &block)).is_a?(String)
        $stderr.puts "Bond Error: "+result
        false
      else
        true
      end
    end

    # See Bond.recomplete
    def recomplete(options={}, &block)
      if (result = agent.recomplete(options, &block)).is_a?(String)
        $stderr.puts "Bond Error: "+result
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
        $stderr.puts "Bond Error: Invalid readline plugin given."
      end
    end

    # See Bond.start
    def start(options={}, &block)
      debrief options
      Array(options[:gems]).each {|e| load_gem_completion(e) }
      load_completions
      Rc.module_eval(&block) if block
      true
    end

    def load_gem_completion(rubygem)
      (file = find_gem_file(rubygem, File.join('bond', 'completions', "#{rubygem}.rb"))) &&
        load_file(file)
    end

    def find_gem_file(rubygem, file)
      begin gem(rubygem); rescue Exception; end
      (dir = $:.find {|e| File.exists?(File.join(e, file)) }) && File.join(dir, file)
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
      $stderr.puts "Bond Error: Completion file '#{file}' failed to load with:", e.message
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