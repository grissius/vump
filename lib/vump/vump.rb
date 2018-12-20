require 'root'

class Vump::Vump
  attr_reader :logger
  def initialize(base_path, arg, options)
    @base_path = base_path
    @arg = arg
    @options = options
    @logger = Vump::Logger.new(options)
    report_start
  end

  def report_start
    @logger.debug("Base path: #{@base_path}")
    @logger.debug("Arguments: #{@arg}")
    @logger.debug("Options: #{@options}")
  end

  def all_modules
    [
      Vump::VersionFile
    ]
  end

  def load_modules
    version_modules = all_modules.map { |m| m.new(@base_path) }
    relevant_modules = version_modules.keep_if(&:relevant?)
    @logger.debug("Loaded modules: #{version_modules.map(&:name)}")
    @logger.debug("Relevant modules: #{relevant_modules.map(&:name)}")
    relevant_modules
  end

  def read_versions(modules)
    modules.map do |mod|
      version = mod.read
      @logger.info("Read current version of \"#{version}\"", mod.name)
      version
    end
  end

  def select_version(versions)
    if versions.uniq.length > 1
      @logger.warn("Inconsitent version records: #{versions}")
      return false
    end
    @logger.info("Single version extracted from all modules: #{versions.first}")
    versions.first
  end

  def write_versions(modules, version)
    modules.map do |mod|
      mod.write(version)
      @logger.info("Writing new version \"#{version}\"", mod.class)
    end
  end

  def start
    modules = load_modules
    version = select_version(read_versions(modules))
    semver = Vump::Semver.new(version)
    semver.bump(@arg)
    write_versions(modules, semver.to_s)
  end
end