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

  context "On a RedHat OS with no package name specified" do
    let :facts do
      {
        :osfamily        => 'RedHat',
      }
    end

    it do
      should contain_package('mcollective-client').with({
        'name'   => 'mcollective-client',
        'ensure' => 'latest',
      })
    end
  end

  context "On a Debian OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it do
      should contain_package('mcollective-client').with({
        'name'   => 'mcollective-client',
        'ensure' => 'latest',
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
      should contain_package('sysutils/mcollective-client').with({
        'name' => 'sysutils/mcollective-client'
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

  describe 'templated client.cfg' do
    context 'With default activemq_base64 parameter (undef)' do
      it 'should NOT contain plugin.activemq.base64 configuration' do
        content = catalogue.resource('file', '/etc/puppetlabs/mcollective/client.cfg').send(:parameters)[:content]
        expect(content).not_to include('plugin.activemq.base64')
      end
    end
    context 'With activemq_base64 parameter set to true' do
      let(:pre_condition) {
        'class { "mcollective":
          hosts           => ["middleware.example.net"],
          client_password => "fakeTestingClientPassword",
          server_password => "fakeTestingServerPassword",
          psk_key         => "fakeTestingPreSharedKey",
          activemq_base64 => true,
        }'
      }
      it 'should contain plugin.activemq.base64 = yes' do
        content = catalogue.resource('file', '/etc/puppetlabs/mcollective/client.cfg').send(:parameters)[:content]
        expect(content).to match(/^plugin\.activemq\.base64 = yes$/)
      end
    end
    context 'With activemq_base64 parameter set to false' do
      let(:pre_condition) {
        'class { "mcollective":
          hosts           => ["middleware.example.net"],
          client_password => "fakeTestingClientPassword",
          server_password => "fakeTestingServerPassword",
          psk_key         => "fakeTestingPreSharedKey",
          activemq_base64 => false,
        }'
      }
      it 'should contain plugin.activemq.base64 = no' do
        content = catalogue.resource('file', '/etc/puppetlabs/mcollective/client.cfg').send(:parameters)[:content]
        expect(content).to match(/^plugin\.activemq\.base64 = no$/)
      end
    end
  end
end
