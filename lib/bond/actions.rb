module Bond
  # Namespace for mission actions.
  module Actions  
    def current_eval(string)
      Missions::ObjectMission.current_eval(string)
    end

    def shell_commands(input)
      ENV['PATH'].split(File::PATH_SEPARATOR).uniq.map {|e| Dir.entries(e) }.flatten.uniq - ['.', '..']
    end
  end
end