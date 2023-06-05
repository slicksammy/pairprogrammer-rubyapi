require_relative '../spec_helper'
require 'cli/actions'
require 'cli/display'
require 'cli/configuration'

RSpec.describe Cli::Actions do
  describe '.run_coder' do
    let(:mock_api_response) {
      { 'running' => false, 'system_message' => { 'explanation' => 'This is an explanation', 'command' => 'comment', 'arguments' => { 'comment' => 'This is a comment.' } } }
    }

    let(:coder_list_response) {
      [{ "requirements": "test", "id": "abcde" }]
    }

    xit 'calls the coder API, displays messages, and shows a comment' do
      config = instance_double('Cli::Configuration')
      allow(Cli::Configuration).to receive(:new).and_return(config)
    
      allow(PairProgrammer::Api::Coder).to receive(:list).and_return(coder_list_response)
      allow(PairProgrammer::Api::Coder).to receive(:run).and_return(mock_api_response)

      expect(Cli::Display).to receive(:info_message).with('This is an explanation').ordered
      expect(Cli::Display).to receive(:message).with('assistant', 'This is a comment.').ordered

      Cli::Actions.run_coder({})
    end
  end
end