require 'spec_helper'

describe 'mcollective::facts::cronjob' do
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
        should contain_cron('mcollective-facts')
    end

    it do
        should compile.with_all_deps
    end
  end
end
