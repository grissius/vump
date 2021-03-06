require 'git'
require 'logger'

module Vump
  class Git
    def initialize(base, options = {})
      @base = base
      @options = options
      @logger = options[:logger]
      @git = ::Git.open(base)
    rescue ArgumentError
      @git = nil
    end

    def loaded?
      !@git.nil?
    end

    def stage(files)
      @logger.debug("Staging files: #{files}") if @logger
      @git.add(files) unless @options[:dry]
      @logger.debug('Files staged') if @logger
    end

    def commit(version)
      message = "Release version #{version}"
      result = @options[:dry] ? 'Dry run success' : @git.commit(message)
      if @logger
        if result != ''
          @logger.info("Created commit #{message.yellow}")
        else
          @logger.error('Could not commit files. Perhaps the hook failed.')
        end
      end
      result == '' ? false : message
    end

    def tag(version_tag)
      @git.add_tag(version_tag) unless @options[:dry]
      @logger.info("Created tag #{version_tag.yellow}") if @logger
    end

    def ignored?(path)
      system("cd #{@base} && git check-ignore #{path}")
    end
  end
end
