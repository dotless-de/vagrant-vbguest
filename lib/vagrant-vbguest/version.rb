require "delegate"

module VagrantVbguest
  VERSION = File.read(File.expand_path("../../../VERSION", __FILE__)).chop

  # Helper to create a new Gem::Version by parsing the common version pattern.
  # When overwriting the pattern, make sure that the matched version string is
  # the capture `1`
  #
  # @param input [String] The text to parse for a version.
  # @param pattern [Regexp] The optional overwrite of the version string pattern (see +PATTERN+)
  # @return [nil|Gem::Version] returns `nil` if the input could not been pared
  def self.Version(input, pattern = /(\d+\.\d+\.\d+)/)
    if input.nil?
      nil
    elsif Gem::Version === input
      input
    else
      Gem::Version.create(input[pattern, 1])
    end
  end
end
