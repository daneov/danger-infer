require 'net/http'
require 'uri'
require 'json'
require 'open3'

module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Daneo Van Overloop/danger-infer
  # @tags monday, weekends, time, rattata
  #
  class DangerInfer < Plugin
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    # attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def analyze(files, comp_db)
      if files.class != Array
        raise ArgumentError, "Expecting Array, instead received #{files.class}"
      end
      paths = sanitize(files).join(',')

      Open3.popen2e('infer --sources',
                    "'#{paths}'",
                    '--results-dir danger-infer',
                    '--clang-compilation-db-files',
                    "'#{comp_db}'") do |_stdin, stdout_and_stderr, wait_thr|
        unless wait_thr.value.success?
          while (line = stdout_and_stderr.gets)
            puts line
          end
          return nil
        end

        while (line = stdout_and_stderr.gets)
          puts line
        end
      end
    end

    def sanitize(path_array)
      path_array.map do |path|
        path = path.gsub(/{(.*) => (.*)}/, '\2')
        path.strip
      end
    end
  end
end
