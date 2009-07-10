current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'bond/readline'
require 'bond/agent'
require 'bond/mission'

module Bond
  def self.complete(options={}, &block)
    agent.complete(options, &block)
  end

  def self.agent
    @agent ||= Bond::Agent.new
  end
end