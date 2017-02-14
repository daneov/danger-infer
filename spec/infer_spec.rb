require File.expand_path('../spec_helper', __FILE__)

module Danger
  RSpec.describe Danger::DangerInfer, host: :github do
    it 'should be a plugin' do
      expect(Danger::DangerInfer.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @infer = @dangerfile.infer
        @git = DangerfileGitPlugin.new @dangerfile

        # fixture_path = '/support/fixtures/gh_pr.json'
        # cwd = File.read(File.dirname(__FILE__) + fixture_path)

        allow(@git).to receive(:modified_files).and_return([])
      end

      # Some examples for writing tests
      # # You should replace these with your own.

      # it "receives the test_fixture" do
      #   res = @infer.retrieve_files_from_json(@infer.github)
      #   expect(res.not.to be_nil)
      # end

      it 'receives files' do
        result = @infer.sanitize(%w(Derp derped))
        expect(result).to eq %w(Derp derped)
      end
    end
  end
end
