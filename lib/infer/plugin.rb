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
  # @example Let Infer do its work
  #          # Pass an array of changed file names e.g. using git
  #          infer.analyze(git.modified_files, json_compilation_db_file)
  #
  # @see  daneov/danger-infer
  # @tags infer, static, analysis
  #
  class DangerInfer < Plugin
    # Start analysis
    # @param files [Array<String>] the files to perform analysis on
    # @param comp_db [String] the compilation_db.json file
    # @return [Array<String>]
    #

    def analyze(files, comp_db)
      if files.class != Array
        raise ArgumentError, "Expecting Array, instead received #{files.class}"
      end
      paths = sanitize(files).join(',')

      run_analysis(paths, comp_db)
    end

    # Sanitize the paths in the given array
    # @param path_array [Array<String>] paths to remove extranous spaces
    # @return [Array<String>]

    def sanitize(path_array)
      path_array.map do |path|
        path = path.gsub(/{(.*) => (.*)}/, '\2')
        path.strip
      end
    end

    private

    # Pass infer the appropriate options and let it analyse all the things
    # @param files [String] files to analyze in "file1.ex,file2.ex" format
    # @param comp_db [String] json_compilation_database file to analyze
    # @return [Array<String>]

    def run_analysis(paths, comp_db)
      Open3.popen2e('infer --sources',
                    "'#{paths}'",
                    '--results-dir danger-infer',
                    '--clang-compilation-db-files',
                    "'#{comp_db}'") do |_stdin, stdout_and_stderr, wait_thr|

        handle_error(stdout_and_stderr) unless wait_thr.value.success?
        analysis_succeeded(stdout_and_stderr) if wait_thr.value.success?
      end
    end

    # Read the given stream and process it as an error
    # @param stdout [String]
    # @return [void]

    def handle_error(stdout)
      while (line = stdout.gets)
        puts line
      end
    end

    # Read the given stream and treat it as a successful analysis
    # @param stdout [String]
    # @return [void]

    def analysis_succeeded(stdout)
      while (line = stdout.gets)
        puts line
      end
    end
  end
end
