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
    @output_dir = 'danger-infer'
    @result_file_name = 'results'
    # Start analysis
    # @param files [Array<String>] the files to perform analysis on
    # @param comp_db [String] the compilation_db.json file
    # @return [Array<String>]
    def analyze(files, comp_db)
      if files.class != Array
        raise ArgumentError, "Expecting Array, instead received #{files.class}"
      end
      paths = sanitize(files).join(',')

      run_analysis(paths, comp_db, @output_dir)
      process_analysis(@result_file_name, @output_dir)
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

    # Process successful analysis
    # @param dir [String] directory in which the file is located
    # @param result_file_name [String] the json file with the analysis' results
    # @return [Array<String>]
    def process_analysis(dir, result_file_name)
      result_file = File.read("#{dir}/#{result_file_name}")
      results_json = JSON.parse(result_file)

      amount_errors = results_json.count
      parsed_json = parse_result_json_to_hash(results_json)

      { 'Count' => amount_errors }.merge(parsed_json)
    end

    private

    # Read the json and extract the info we need
    # @param results_json [Hash] json with results of the analysis
    # @return [Hash<Hash<Int>>]
    def parse_result_json_to_hash(results_json)
      by_kind = {}
      results_json.each do |record|
        record_severity = record['severity'].capitalize
        record_kind = record['kind'].capitalize

        by_kind[record_kind] ||= {}
        by_kind[record_kind][record_severity] ||= 0

        by_kind[record_kind][record_severity] += 1
      end

      by_kind
    end

    # Pass infer the appropriate options and let it analyse all the things
    # @param paths [String] files to analyze in "file1.ex,file2.ex" format
    # @param comp_db [String] json_compilation_database file to analyze
    # @return [Array<String>]
    def run_analysis(paths, comp_db, output_dir)
      Open3.popen2e('infer --sources',
                    "'#{paths}'",
                    "--results-dir #{output_dir}",
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
