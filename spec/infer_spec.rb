require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerInfer do

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
        
        json = File.read(File.dirname(__FILE__) + '/support/fixtures/gh_pr.json')
        allow(@infer.github).to receive(:pr_json).and_return(json)
        
      end

      # Some examples for writing tests
      # # You should replace these with your own.

      # it "receives the test_fixture" do
      #   res = @infer.retrieve_files_from_json(@infer.github)
      #   expect(res.not.to be_nil)
      # end

      it "receives files" do
        expect(@infer.changed_files).not_to_be nil
      end
    end
  end
end
