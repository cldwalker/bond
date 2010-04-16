class Bond::Missions::AnywhereMission < Bond::Mission
  attr_reader :anywhere_condition
  def initialize(options={}) #:nodoc:
    options[:on] = @anywhere_condition = options.delete(:anywhere)
    super
  end

  def handle_valid_match(input)
    if (match = super)
      @input = @matched[1]
      @completion_prefix = input.sub(/#{@matched[1]}$/, '')
    end
    match
  end

  def unique_id #:nodoc:
    @anywhere_condition
  end
end
