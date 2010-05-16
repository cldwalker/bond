module Bond
  class YardError < StandardError; end
  module Yard
    extend self

    def load_yard_gems(*gems)
      require_yard
      gems.each {|e| load_yard_gem(e) }
    rescue YardError
      $stderr.puts "Bond Error: #{$!.message}"
    end

    def load_yard_gem(rubygem)
      if (yardoc = find_yardoc(rubygem))
        YARD::Registry.load!(yardoc)
        methods_hash = find_methods_with_options
        generate_method_completions(methods_hash)
      else
        raise YardError, "Failed to load yard gem '#{rubygem}'. Unable to find its .yardoc."
      end
    rescue YardError
      $stderr.puts "Bond Error: #{$!.message}"
    end

    def find_yardoc(rubygem)
      (file = YARD::Registry.yardoc_file_for_gem(rubygem)) and return(file)
      if !(file = `gem which #{rubygem}`.chomp).empty?
        output_dir = File.join(yardocs_dir, rubygem)
        cmd = ['yardoc', '-n', '-c', output_dir, '-b', output_dir, file,
          File.expand_path(file+'/..')+"/#{rubygem}/**/*.rb"]
        puts cmd.join(' '), "Generating #{rubygem}'s YARD documentation ..."
        system *cmd
        output_dir
      else
        nil
      end
    end

    def yardocs_dir
      @yardocs_dir ||= begin
        require 'fileutils'; FileUtils.mkdir_p File.join(M.home, '.bond', '.yardocs')
        File.join(M.home, '.bond', '.yardocs')
      end
    end

    def find_methods_with_options
      YARD::Registry.all(:method).inject({}) {|a,m|
        opts = m.tags.select {|e| e.is_a?(YARD::Tags::OptionTag) }.map {|e| e.pair.name }
        a[m.path] = opts if !opts.empty? ; a
      }
    end

    def generate_method_completions(methods_hash)
      str = ''
      methods_hash.each do |meth, options|
        options.map! {|e| e.sub(/^:/, '') }
        str << %Q[complete(:method=>'#{meth}') {\n  #{options.inspect}\n}\n]
      end
      puts str
    end

    def require_yard
      require 'yard'
    rescue LoadError
      raise YardError, "yard gem not installed"
    end
  end
end