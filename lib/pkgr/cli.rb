require "thor"
require 'pkgr'
require 'pkgr/buildpack'
require 'pkgr/env'

module Pkgr
  class CLI < Thor
    class_option :verbose,
      :type => :boolean,
      :default => false,
      :desc => "Run verbosely"
    class_option :debug,
      :type => :boolean,
      :default => false,
      :desc => "Run very verbosely"
    class_option :name,
      :type => :string,
      :desc => "Application name (if directory given, it will default to the directory name)"
    class_option :buildpacks_cache_dir,
      :type => :string,
      :desc => "Directory where to store the buildpacks",
      :default => Pkgr::Buildpack.buildpacks_cache_dir

    desc "package TARBALL", "Package the given tarball or directory"

    method_option :buildpack,
      :type => :string,
      :desc => "Custom buildpack to use"
    method_option :target,
      :type => :string,
      :default => "deb",
      :desc => "Target package to build (only 'deb' supported for now)"
    method_option :changelog,
      :type => :string,
      :desc => "Changelog"
    method_option :architecture,
      :type => :string,
      :default => "x86_64",
      :desc => "Target architecture for the package"
    method_option :homepage,
      :type => :string,
      :desc => "Project homepage"
    method_option :description,
      :type => :string,
      :desc => "Project description"
    method_option :version,
      :type => :string,
      :desc => "Package version (if git directory given, it will use the latest git tag available)"
    method_option :iteration,
      :type => :string,
      :default => Time.now.strftime("%Y%m%d%H%M%S"),
      :desc => "Package iteration (you should keep the default here)"
    method_option :user,
      :type => :string,
      :desc => "User to run the app under (defaults to your app name)"
    method_option :group,
      :type => :string,
      :desc => "Group to run the app under (defaults to your app name)"
    method_option :compile_cache_dir,
      :type => :string,
      :desc => "Where to store the files cached between packaging runs. Path will be resolved from the temporary code repository folder, so use absolute paths if needed."
    method_option :before_precompile,
      :type => :string,
      :desc => "Provide a script to run just before the buildpack compilation. Path will be resolved from the temporary code repository folder, so use absolute paths if needed."
    method_option :dependencies,
      :type => :array,
      :default => [],
      :desc => "Specific system dependencies that you want to install with the package"
    method_option :build_dependencies,
      :type => :array,
      :default => [],
      :desc => "Specific system dependencies that must be present before building"
    method_option :host,
      :type => :string,
      :desc => "Remote host to build on (default: local machine)"
    method_option :auto,
      :type => :boolean,
      :default => false,
      :desc => "Automatically attempt to install missing dependencies"
    method_option :clean,
      :type => :boolean,
      :default => true,
      :desc => "Automatically clean up temporary dirs"
    method_option :edge,
      :type => :boolean,
      :default => true,
      :desc => "Always use the latest version of the buildpack if already installed"
    method_option :env,
      :type => :array,
      :default => [],
      :desc => 'Specify environment variables for buildpack (--env "CURL_TIMEOUT=2" "BUNDLE_WITHOUT=development test")'
    method_option :force_os,
      :type => :string,
      :desc => 'Force a specific distribution to build for (e.g. --force-os "debian-wheezy")'

    def package(tarball)
      Pkgr.level = Logger::INFO if options[:verbose]
      Pkgr.level = Logger::DEBUG if options[:debug]

      Pkgr::Buildpack.buildpacks_cache_dir = options[:buildpacks_cache_dir] if options[:buildpacks_cache_dir]

      packager = Dispatcher.new(tarball, options)
      packager.call
    rescue Pkgr::Errors::Base => e
      Pkgr.error "#{e.class.name} : #{e.message}"
      puts "* ERROR: #{e.message}"
      exit 1
    end
  end
end
