module Vump
  # Representation of version notation according to https://semver.org/
  class Semver
    def initialize(string)
      # <numeral>[-<sufix>]
      version, sufix = string
                       .match(/([\d\.]+)(?:\-)?(.*)?/)
                       .captures
      # <sufix>:= [<pre>][+<build>]
      @pre, @build = sufix.split('+', 2).map { |s| s.empty? ? false : s }
      # <numeral>:= <major>.<minor>.<patch>
      @major, @minor, @patch = version
                               .match(/(\d+)\.(\d+)\.(\d+)/)
                               .captures
                               .map(&:to_i)
    end

    def reset(what)
      levels = %i[@build @pre @patch @minor @major]
      # tag to false, version to 0
      reset_to = %i[@build @pre].include?(what) ? false : 0
      instance_variable_set(what, reset_to)
      # reset lesser sections
      reset levels[levels.index(what) - 1] if levels.index(what) != 0
    end

    def bump_patch
      reset :@pre
      @patch += 1
    end

    def bump_minor
      reset :@patch
      @minor += 1
    end

    def bump_major
      reset :@minor
      @major += 1
    end

    def to_s
      str = "#{@major}.#{@minor}.#{@patch}"
      str << "-#{@pre}" if @pre
      str << "+#{@build}" if @build
      str
    end
  end
end
