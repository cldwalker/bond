module Bond
  module Search
    def default_search(input, list)
      list.grep(/^#{input}/)
    end

    def anywhere_search(input, list)
      list.grep(/#{input}/)
    end

    def ignore_case_search(input, list)
      list.grep(/#{input}/i)
    end

    def underscore_search(input, list)
      split_input = input.split("-").join("")
      list.select {|c|
        c.split("_").map {|g| g[0,1] }.join("") =~ /^#{split_input}/ || c =~ /^#{input}/
      }
    end
  end
end