module Bond
  module M
    extend self

    def agent #:nodoc:
      @agent ||= Agent.new(config)
    end

    def config #:nodoc:
      @config ||= {:readline_plugin=>Bond::Readline, :debug=>false}
    end

    # Resets Bond so that next time Bond.complete is called, a new set of completion missions are created. This does not
    # change current completion behavior.
    def reset
      MethodMission.reset
      @agent = nil
    end

    # Reports what completion mission and possible completions would happen for a given input. Helpful for debugging
    # your completion missions.
    # ==== Example:
    #   >> Bond.spy "shoot oct"
    #   Matches completion mission for method matching "shoot".
    #   Possible completions: ["octopussy"]
    def spy(input)
      agent.spy(input)
    end

    # Debriefs Bond to set global defaults. Call before defining completions.
    # ==== Options:
    # [*:readline_plugin*] Specifies a Bond plugin to interface with a Readline-like library. Available plugins are Bond::Readline
    #                      and Bond::Rawline. Defaults to Bond::Readline. Note that a plugin doesn't imply use with irb. Irb is
    #                      joined to the hip with Readline.
    # [*:default_mission*] A proc to be used as the default completion proc when no completions match or one fails. When in irb
    #                      with completion enabled, uses irb completion. Otherwise defaults to a proc with an empty completion list.
    # [*:default_search*] A symbol or proc to be used as the default search in completions. See Bond.complete's :search option for valid symbols.
    # [*:eval_binding*] Specifies a binding to be used when evaluating objects in ObjectMission and MethodMission. When in irb,
    #                   defaults to irb's main binding. Otherwise defaults to TOPLEVEL_BINDING.
    # [*:debug*]  Boolean to print unexpected errors when autocompletion fails. Default is false.
    #
    # ==== Example:
    #   Bond.debrief :default_search=>:underscore, :default_mission=>:default
    def debrief(options={})
      config.merge! options
      plugin_methods = %w{setup line_buffer}
      unless config[:readline_plugin].is_a?(Module) &&
        plugin_methods.all? {|e| config[:readline_plugin].instance_methods.map {|f| f.to_s}.include?(e)}
        $stderr.puts "Invalid readline plugin set. Try again."
      end
    end

    # Loads bond/completion, optional ~/.bondrc, plugins in lib/bond/completions/ and
    # ~/.bond/completions/ and optional block.
    # See Rc for syntax to use in ~/.bondrc and plugins.
    def load(&block)
      debrief(:default_search=>:underscore) unless config[:default_search]
      debrief(:default_mission=>:default) unless config[:default_mission]
      Rc.load File.join(File.dirname(__FILE__), 'completion.rb')
      Rc.load(File.join(home,'.bondrc')) if File.exists?(File.join(home, '.bondrc'))
      [File.dirname(__FILE__), File.join(home, '.bond')].each do |base_dir|
        load_completions(base_dir)
      end
      Rc.module_eval(&block) if block
      true
    end

    def load_completions(base_dir) #:nodoc:
      if File.exists?(dir = File.join(base_dir, 'completions'))
        Dir[dir + '/*.rb'].each {|file| Rc.load(file) }
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