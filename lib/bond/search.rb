module Bond
  # Contains search methods used to filter possible completions given what the user has typed for that completion.
  # For a search method to be used by Bond.complete it must end in '_search' and take two arguments: the input
  # string and an array of possible completions.
  module Search
    # Searches completions from the beginning of the string.
    def default_search(input, list)
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

    # Searches completions from the beginning but also provides aliasing of underscored words.
    # For example 'some_dang_long_word' can be specified as 's_d_l_w'. Aliases can be any unique string
    # at the beginning of an underscored word. For example, to choose the first completion between 'so_long' and 'so_larger',
    # type 's_lo'.
    def underscore_search(input, list)
      if input[/_(.+)$/]
        regex = input.split('_').map {|e| Regexp.escape(e) }.join("([^_]+)?_")
        list.select {|e| e =~ /^#{regex}/ }
      else
        default_search(input, list)
      end
    end
  end
end