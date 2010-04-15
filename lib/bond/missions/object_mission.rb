# Represents a completion mission specified by :object in Bond.complete. Unlike other missions, this
# one needs to both match the mission condition and have the current object being completed have
# an ancestor specified by :object.
class Bond::Missions::ObjectMission < Bond::Mission
  #:stopdoc:
  attr_reader :object_condition

  def initialize(options={})
    @object_condition = options.delete(:object)
    @object_condition = /^#{Regexp.escape(@object_condition.to_s)}$/ unless @object_condition.is_a?(Regexp)
    options[:on] ||= /(\S+|[^.]+)\.([^.\s]*)$/
    @eval_binding = options[:eval_binding]
    super
  end

  def unique_id
    "#{@object_condition.inspect}+#{@condition.inspect}"
  end

  def handle_valid_match(input)
    if (match = super)
      begin
        eval_object(match)
      rescue Exception
        return false
      end
      if @evaled_object.class.respond_to?(:ancestors) &&
        (match = @evaled_object.class.ancestors.any? {|e| e.to_s =~ @object_condition })
        @completion_prefix = @matched[1] + "."
        @input = @matched[2]
        @input.instance_variable_set("@object", @evaled_object)
        @input.instance_eval("def self.object; @object ; end")
        @action ||= lambda {|e| default_action(e.object) }
      else
        match = false
      end
    end
    match
  end

  def eval_object(match)
    @matched = match
    @evaled_object = self.class.current_eval(match[1], @eval_binding)
  end

  def default_action(obj)
    obj.methods.map {|e| e.to_s} - OPERATORS
  end
  #:startdoc:
end