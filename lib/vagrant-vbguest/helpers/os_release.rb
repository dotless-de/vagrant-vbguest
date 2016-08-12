# This file uses a the parsing component of the environment file parser
# dotenv (https://github.com/bkeepers/dotenv) in order to parse the
# `/etc/os-release` file of systemd, which uses loosely the same format.
#
# This parser will only substitute env variables in values which are already
# present in the parsed Hash. The original parser would try to read it's value
# from the `ENV` the process is running in. We would need to run this on the
# vagrant guest.
#
# Example:
#
#     FOO=123
#     BAR=$FOO  # => `"BAR" => "123"`
#     BAZ=$ZORT # => `"BAZ" => "$ZORT"
#
# This parser will *not* try to substitute shell commands in a value, since it
# would require us to let it run on the guest system.
#
# Example:
#
#     SHA=$(git rev-parse HEAD) # => "SHA"=>"$(git rev-parse HEAD)"
#

# The original code (https://github.com/bkeepers/dotenv) was licensed under:
#
# Copyright (c) 2012 Brandon Keepers
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "English"

module VagrantVbguest
  module Helpers
    module OsRelease
      class FormatError < SyntaxError; end

      module Substitutions
        # Substitute variables in a value.
        #
        #   HOST=example.com
        #   URL="https://$HOST"
        #
        module Variable
          class << self
            VARIABLE = /
              (\\)?         # is it escaped with a backslash?
              (\$)          # literal $
              (?!\()        # shouldnt be followed by paranthesis
              (\{)?         # allow brace wrapping
              ([A-Z0-9_]+)? # optional alpha nums
              (\})?         # closing brace
            /xi

            def call(value, env)
              value.gsub(VARIABLE) do |variable|
                match = $LAST_MATCH_INFO

                if match[1] == '\\'
                  variable[1..-1]
                elsif match[4]
                  env.fetch(match[4]) { match[2..5].join }
                else
                  variable
                end
              end
            end
          end
        end
      end

      # This class enables parsing of a string for key value pairs to be returned
      # and stored in the Environment. It allows for variable substitutions and
      # exporting of variables.
      class Parser
        @substitutions = [Substitutions::Variable]

        LINE = /
          \A
          (?:export\s+)?    # optional export
          ([\w\.]+)         # key
          (?:\s*=\s*|:\s+?) # separator
          (                 # optional value begin
            '(?:\'|[^'])*'  #   single quoted value
            |               #   or
            "(?:\"|[^"])*"  #   double quoted value
            |               #   or
            [^#\n]+         #   unquoted value
          )?                # value end
          (?:\s*\#.*)?      # optional comment
          \z
        /x

        class << self
          attr_reader :substitutions

          def call(string)
            new(string).call
          end
        end

        def initialize(string)
          @string = string
          @hash = {}
        end

        def call
          @string.split(/[\n\r]+/).each do |line|
            parse_line(line)
          end
          @hash
        end

        private

        def parse_line(line)
          if (match = line.match(LINE))
            key, value = match.captures
            @hash[key] = parse_value(value || "")
          elsif line.split.first == "export"
            if variable_not_set?(line)
              raise FormatError, "Line #{line.inspect} has an unset variable"
            end
          elsif line !~ /\A\s*(?:#.*)?\z/ # not comment or blank line
            raise FormatError, "Line #{line.inspect} doesn't match format"
          end
        end

        def parse_value(value)
          # Remove surrounding quotes
          value = value.strip.sub(/\A(['"])(.*)\1\z/, '\2')

          if Regexp.last_match(1) == '"'
            value = unescape_characters(expand_newlines(value))
          end

          if Regexp.last_match(1) != "'"
            self.class.substitutions.each do |proc|
              value = proc.call(value, @hash)
            end
          end
          value
        end

        def unescape_characters(value)
          value.gsub(/\\([^$])/, '\1')
        end

        def expand_newlines(value)
          value.gsub('\n', "\n").gsub('\r', "\r")
        end

        def variable_not_set?(line)
          !line.split[1..-1].all? { |var| @hash.member?(var) }
        end
      end
    end
  end
end
