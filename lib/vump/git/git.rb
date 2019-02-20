require 'git'
require 'logger'

module Vump
  class Git
    def initialize(base, options = {})
      @git = ::Git.open(base)
      @logger = options[:logger]
    rescue ArgumentError
      @git = nil
    end

    def loaded?
      !@git.nil?
    end

    def stage(files)
      @logger.debug("Staging files: #{files}") if @logger
      @git.add(files)
      @logger.debug('Files staged') if @logger
    end

    def commit(version)
      message = "Release version #{version}"
      result = @git.commit(message)
      if @logger
        if result
          @logger.info("Created commit #{message}")
        else
          @logger.error('Could not commit files. Perhaps the hook failed.')
        end
      end
      result == '' ? false : message
    end

    def tag(version_tag)
      @git.add_tag(version_tag)
      @logger.info("Created tag #{version_tag}") if @logger
    end
  end
end