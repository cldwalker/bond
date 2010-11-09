module Bond
  # Takes international quagmires (a user's completion setup) and passes them on as missions to an Agent.
  module M
    extend self

    # See {Bond#complete}
    def complete(options={}, &block)
      if (result = agent.complete(options, &block)).is_a?(String)
        $stderr.puts "Bond Error: "+result
        false
      else
        true
      end
    end

    # See {Bond#recomplete}
    def recomplete(options={}, &block)
      if (result = agent.recomplete(options, &block)).is_a?(String)
        $stderr.puts "Bond Error: "+result
        false
      else
        true
      end
    end

    # See {Bond#agent}
    def agent
      @agent ||= Agent.new(config)
    end

    # See {Bond#config}
    def config
      @config ||= {:readline_plugin=>Bond::Readline, :debug=>false, :default_search=>:underscore}
    end

    # Resets M's missions and config
    def reset
      MethodMission.reset
      @config = @agent = nil
    end

    # See {Bond#spy}
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

    # See {Bond#restart}
    def restart(options={}, &block)
      reset
      start(options, &block)
    end

    # See {Bond#start}
    def start(options={}, &block)
      debrief options
      @started = true
      load_completions
      Rc.module_eval(&block) if block
      true
    end

    # See {Bond#started?}
    def started?
      !!@started
    end

    # Finds the full path to a gem's file relative it's load path directory. Returns nil if not found.
    def find_gem_file(rubygem, file)
      begin gem(rubygem); rescue Exception; end
      (dir = $:.find {|e| File.exists?(File.join(e, file)) }) && File.join(dir, file)
    end

    # Loads a completion file in Rc namespace.
    def load_file(file)
      Rc.module_eval File.read(file)
    rescue Exception => e
      $stderr.puts "Bond Error: Completion file '#{file}' failed to load with:", e.message
    end

    # Loads completion files in given directory.
    def load_dir(base_dir)
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

    protected
    def load_gem_completion(rubygem)
      (dir = find_gem_file(rubygem, File.join(rubygem, '..', 'bond'))) ?
        load_dir(dir) : $stderr.puts("Bond Error: No completions found for gem '#{rubygem}'.")
    end

    def load_gems(*gems)
      gems.select {|e| load_gem_completion(e) }
    end

    def load_completions
      load_file File.join(File.dirname(__FILE__), 'completion.rb')
      load_dir File.dirname(__FILE__)
      load_gems *config[:gems] if config[:gems]
      Yard.load_yard_gems *config[:yard_gems] if config[:yard_gems]
      load_file(File.join(home,'.bondrc')) if File.exists?(File.join(home, '.bondrc'))
      load_dir File.join(home, '.bond')
    end
  end
end
