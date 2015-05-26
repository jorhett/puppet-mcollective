require 'spec_helper'

describe 'mcollective::server' do
  let(:pre_condition) { 
    'class { "mcollective":
      hosts           => ["middleware.example.net"],                                                                                                                                                         
      client_password => "fakeTestingClientPassword",
      server_password => "fakeTestingServerPassword",
      psk_key         => "fakeTestingPreSharedKey",
    }'
  }

  context 'with defaults for all parameters' do
    it { should contain_package('mcollective') }

    it { should compile.with_all_deps }
  end

  context "With a package name specified" do
    let :params do
      {
        :package => 'mcollectived'
      }
    end

    it {
      should contain_package('mcollectived').with( { 'name' => 'mcollectived' } )
    }
  end

  context "On a RedHat OS with no package name specified" do
    let :facts do
      {
        :osfamily        => 'RedHat',
      }
    end

    it do
      should contain_package('mcollective').with({
        'name'   => 'mcollective',
        'ensure' => 'latest',
      })
      should contain_service('mcollective').with({
        'name'   => 'mcollective',
        'ensure' => 'running',
      })
    end
  end

  context "On a Debian OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end
    let(:pre_condition) do
     'include mcollective::params'
    end

    it do
      should contain_package('mcollective').with({
        'name'   => 'mcollective',
        'ensure' => 'latest',
      })
      should contain_service('mcollective').with({
        'name'   => 'mcollective',
        'ensure' => 'running',
      })
    end
  end

  context "On a FreeBSD OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'FreeBSD'
      }
    end

    it do
      should contain_package('sysutils/mcollective').with({
        'name' => 'sysutils/mcollective',
      })
      should contain_service('mcollectived').with({
        'name' => 'mcollectived',
        'ensure' => 'running',
      })
    end
  end

  context "On an unknown OS with no stomp package name specified" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it do
      should contain_package('rubygem-stomp').with({ 'name' => 'rubygem-stomp' })
    end
  end
end
