module Bond
  # Takes international quagmires (a user's completion setup) and passes them on
  # as missions to an Agent.
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
      @config ||= {:debug => false, :default_search => :underscore}
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
      config[:readline] ||= default_readline
      if !config[:readline].is_a?(Module) &&
        Bond.const_defined?(config[:readline].to_s.capitalize)
        config[:readline] = Bond.const_get(config[:readline].to_s.capitalize)
      end
      unless %w{setup line_buffer}.all? {|e| config[:readline].respond_to?(e) }
        $stderr.puts "Bond Error: Invalid readline plugin '#{config[:readline]}'."
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

    # Finds the full path to a gem's file relative it's load path directory.
    # Returns nil if not found.
    def find_gem_file(rubygem, file)
      begin gem(rubygem); rescue Exception; end
      (dir = $:.find {|e| File.exist?(File.join(e, file)) }) && File.join(dir, file)
    end

    # Loads a completion file in Rc namespace.
    def load_file(file)
      Rc.module_eval File.read(file)
    rescue Exception => e
      $stderr.puts "Bond Error: Completion file '#{file}' failed to load with:", e.message
    end

    # Loads completion files in given directory.
    def load_dir(base_dir)
      if File.exist?(dir = File.join(base_dir, 'completions'))
        Dir[dir + '/*.rb'].each {|file| load_file(file) }
        true
      end
    end

    # Loads completions from gems
    def load_gems(*gems)
      gems.select {|e| load_gem_completion(e) }
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
    def default_readline
      RUBY_PLATFORM[/mswin|mingw|bccwin|wince/i] ? Ruby :
        RUBY_PLATFORM[/java/i] ? Jruby : Bond::Readline
    end

    def load_gem_completion(rubygem)
      (dir = find_gem_file(rubygem, File.join(rubygem, '..', 'bond'))) ? load_dir(dir) :
        rubygem[/\/|-/] ? load_plugin_file(rubygem) :
        $stderr.puts("Bond Error: No completions found for gem '#{rubygem}'.")
    end

    def load_plugin_file(rubygem)
      namespace, file = rubygem.split(/\/|-/, 2)
      file += '.rb' unless file[/\.rb$/]
      if (dir = $:.find {|e| File.exist?(File.join(e, namespace, 'completions', file)) })
        load_file File.join(dir, namespace, 'completions', file)
        true
      end
    end

    def load_completions
      load_file File.join(File.dirname(__FILE__), 'completion.rb') unless config[:bare]
      load_dir File.dirname(__FILE__) unless config[:bare]
      load_gems *config[:gems] if config[:gems]
      load_file(File.join(home,'.bondrc')) if File.exist?(File.join(home, '.bondrc')) && !config[:bare]
      load_dir File.join(home, '.bond') unless config[:bare]
    end
  end
end
