require 'spec_helper'

describe 'mcollective::middleware' do
  let(:pre_condition) do
    'class { "mcollective":
      hosts           => ["middleware.example.net"],                                                                                                                                                         
      client_password => "fakeTestingClientPassword",
      server_password => "fakeTestingServerPassword",
      psk_key         => "fakeTestingPreSharedKey",
    }'
  end

  let(:params) do
    {
    } 
  end

  context 'with defaults for all parameters' do
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

  context 'with defaults for all parameters' do
    it do
        should contain_package('activemq')
    end

    it do
        should compile.with_all_deps
    end
  end

  context "With the rabbitmq package name specified" do
    let :params do
      {
        :package => 'rabbitmq'
      }
    end

    it do
      should contain_package('rabbitmq').with( { 'name' => 'rabbitmq' } )
    end
  end
end
