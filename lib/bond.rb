current_dir = File.dirname(__FILE__)
$:.unshift(current_dir) unless $:.include?(current_dir) || $:.include?(File.expand_path(current_dir))
require 'bond/readline'
require 'bond/rawline'
require 'bond/agent'
require 'bond/mission'
require 'bond/missions/default_mission'
require 'bond/missions/method_mission'
require 'bond/missions/object_mission'

module Bond
  extend self

  def complete(options={}, &block)
    agent.complete(options, &block)
    true
  rescue InvalidMissionError
    $stderr.puts "Invalid mission given. Mission needs an action and a condition."
    false
  rescue
    $stderr.puts "Mission setup failed with:", $!
    false
  end

  def agent
    @agent ||= Agent.new(config)
  end

  def reset
    @agent = nil
  end

  # Options:
  # [:readline_plugin]
  # [:default_mission]
  # [:eval_binding]
  def debrief(options={})
    config.merge! options
    plugin_methods = %w{setup line_buffer}
    unless config[:readline_plugin].is_a?(Module) && plugin_methods.all? {|e| config[:readline_plugin].instance_methods.include?(e)}
      $stderr.puts "Invalid readline plugin set. Try again."
    end
  end

  def config
    @config ||= {:readline_plugin=>Bond::Readline}
  end
end