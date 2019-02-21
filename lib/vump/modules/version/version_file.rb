require 'vump/modules/version/base_file_module'

module Vump
  class VersionFile < BaseFileVersionModule
    def filename
      'VERSION'
    end

    def select(contents)
      contents.strip
    end

    def compose(_contents, version)
      "#{version}\n"
    end
  end
end
