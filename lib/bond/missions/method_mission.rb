# Created with :method in Bond.complete. Is able to complete first argument for a method.
class Bond::Missions::MethodMission < Bond::Mission
  def self.create(options)
    return Bond::Missions::ObjectMethodMission.new(options) if options[:method] == true
    (options[:methods] || Array(options[:method])).each do |meth|
      meth = "Kernel##{meth}" if !meth.to_s[/[.#]/]
      Bond::Missions::ObjectMethodMission.add_method_action(meth, &options[:action])
    end
    nil
  end
end
