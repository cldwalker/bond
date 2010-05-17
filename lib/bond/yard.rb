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
        completion_file = File.join(dir('yard_completions'), rubygem+'.rb')
        unless File.exists? completion_file
          YARD::Registry.load!(yardoc)
          methods_hash = find_methods_with_options
          body = generate_method_completions(methods_hash)
          File.open(completion_file, 'w') {|e| e.write body }
        end
        M.load_file completion_file
      else
        raise YardError, "Failed to load yard gem '#{rubygem}'. Unable to find its .yardoc."
      end
    rescue YardError
      $stderr.puts "Bond Error: #{$!.message}"
    end

    def find_yardoc(rubygem)
      (file = YARD::Registry.yardoc_file_for_gem(rubygem)) and return(file)
      if (file = M.find_gem_file(rubygem, rubygem+'.rb'))
        output_dir = File.join(dir('.yardocs'), rubygem)
        cmd = ['yardoc', '-n', '-c', output_dir, '-b', output_dir, file,
          File.expand_path(file+'/..')+"/#{rubygem}/**/*.rb"]
        puts cmd.join(' '), "Generating #{rubygem}'s YARD documentation ..."
        system *cmd
        output_dir
      end
    end

    def dir(subdir)
      (@dirs ||= {})[subdir] ||= begin
        require 'fileutils'; FileUtils.mkdir_p File.join(M.home, '.bond', subdir)
        File.join(M.home, '.bond', subdir)
      end
    end

    def find_methods_with_options
      YARD::Registry.all(:method).inject({}) {|a,m|
        opts = m.tags.select {|e| e.is_a?(YARD::Tags::OptionTag) }.map {|e| e.pair.name }
        a[m.path] = opts if !opts.empty? ; a
      }
    end

    def generate_method_completions(methods_hash)
      methods_hash.map do |meth, options|
        options.map! {|e| e.sub(/^:/, '') }
        %Q[complete(:method=>'#{meth}') {\n  #{options.inspect}\n}]
      end.join("\n")
    end

    def require_yard
      require 'yard'
    rescue LoadError
      raise YardError, "yard gem not installed"
    end
  end
end