require 'spec_helper'

describe 'mcollective' do
  let(:params) do
    {
      :hosts           => ['middleware.example.net'],
      :client_password => 'fakeTestingClientPassword',
      :server_password => 'fakeTestingServerPassword',
      :psk_key         => 'fakeTestingPreSharedKey',
    } 
  end

  context 'with defaults for all parameters' do
    it do
        should contain_class('mcollective')
        should contain_class('mcollective::params')
    end

    it do
      should compile.with_all_deps
    end
  end

  # Now test for failures
  context "Without a list of hosts" do
    let(:params) do {
      :hosts           => nil,
      :client_password => 'fakeTestingClientPassword',
      :server_password => 'fakeTestingServerPassword',
      :psk_key         => 'fakeTestingPreSharedKey',
    } end

    it do
      expect { should raise_error(Puppet::Error) }
    end
  end

  context "Without a client password" do
    let(:params) do {
      :hosts           => ['middleware.example.net'],
      :client_password => nil,
      :server_password => 'fakeTestingServerPassword',
      :psk_key         => 'fakeTestingPreSharedKey',
    } end

    it do
      expect { should raise_error(Puppet::Error) }
    end
  end

  context "Without a server password" do
    let(:params) do {
      :hosts           => ['middleware.example.net'],
      :client_password => 'fakeTestingClientPassword',
      :server_password => nil,
      :psk_key         => 'fakeTestingPreSharedKey',
    } end

    it do
      expect { should raise_error(Puppet::Error) }
    end
  end

  context "Without a pre-shared key" do
    let(:params) do {
      :hosts           => ['middleware.example.net'],
      :client_password => 'fakeTestingClientPassword',
      :server_password => 'fakeTestingServerPassword',
      :psk_key         => nil,
    } end

    it do
      expect { should raise_error(Puppet::Error) }
    end
  end

  #at_exit { RSpec::Puppet::Coverage.report! }
end
