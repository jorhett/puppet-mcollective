require 'spec_helper'

describe 'mcollective::client' do
  let(:pre_condition) do
    'class { "mcollective":
      hosts           => ["middleware.example.net"],                                                                                                                                                         
      client_password => "fakeTestingClientPassword",
      server_password => "fakeTestingServerPassword",
      psk_key         => "fakeTestingPreSharedKey",
    }'
  end

  context 'with defaults for all parameters' do
    it do
        should contain_package('mcollective-client')
    end

    it do
        should compile.with_all_deps
    end
  end

  context "With a package name specified" do
    let :params do
      {
        :package => 'mcollective-client'
      }
    end

    it do
      should contain_package('mcollective-client').with( { 'name' => 'mcollective-client' } )
    end
  end
end
