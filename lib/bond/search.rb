module Bond
  # Contains search methods used to filter possible completions given what the user has typed for that completion.
  # For a search method to be used by Bond.complete it must end in '_search' and take two arguments: the Input
  # string and an array of possible completions.
  #
  # ==== Creating a search method
  # Say you want to create a custom search which ignores completions containing '-'.
  # In a completion file under Rc namespace, define this method:
  #   def ignore_hyphen_search(input, list)
  #     normal_search(input, list.select {|e| e !~ /-/ })
  #   end
  #
  # Now you can pass this custom search to any complete() as :search => :ignore_hyphen
  module Search
    class<<self
      # Default search used across missions, set by Bond.config[:default_search]
      attr_accessor :default_search
    end

    # Searches completions from the beginning of the string.
    def normal_search(input, list)
      list.grep(/^#{Regexp.escape(input)}/)
    end

    # Searches completions anywhere in the string.
    def anywhere_search(input, list)
      list.grep(/#{Regexp.escape(input)}/)
    end

    # Searches completions from the beginning and ignores case.
    def ignore_case_search(input, list)
      list.grep(/^#{Regexp.escape(input)}/i)
    end

    # A normal_search which also provides aliasing of underscored words.
    # For example 'some_dang_long_word' can be specified as 's_d_l_w'. Aliases can be any unique string
    # at the beginning of an underscored word. For example, to choose the first completion between 'so_long'
    # and 'so_larger', type 's_lo'.
    def underscore_search(input, list)
      if input[/_([^_]+)$/]
        regex = input.split('_').map {|e| Regexp.escape(e) }.join("([^_]+)?_")
        list.select {|e| e =~ /^#{regex}/ }
      else
        normal_search(input, list)
      end
    end

    # Default search across missions to be invoked by a search that wrap another search i.e. files_search.
    def default_search(input, list)
      send("#{Search.default_search}_search", input, list)
    end

    # Does default_search on the given paths but only returns ones that match the input's current
    # directory depth, determined by '/'. For example if a user has typed 'irb/c', this search returns
    # matching paths that are one directory deep i.e. 'irb/cmd/ irb/completion.rb irb/context.rb'.
    def files_search(input, list)
      incremental_filter(input, list, '/')
    end

    # Does the same as files_search but for modules. A module depth is delimited by '::'.
    def modules_search(input, list)
      incremental_filter(input, list, '::')
    end

    # Used by files_search and modules_search.
    def incremental_filter(input, list, delim)
      i = 0; input.gsub(delim) {|e| i+= 1 }
      delim_chars = delim.split('').uniq.join('')
      current_matches, future_matches = default_search(input, list).partition {|e|
        e[/^[^#{delim_chars}]*(#{delim}[^#{delim_chars}]+){0,#{i}}$/] }
      (current_matches + future_matches.map {|e| e[/^(([^#{delim_chars}]*#{delim}){0,#{i+1}})/, 1] }).uniq
    end
  end
end
