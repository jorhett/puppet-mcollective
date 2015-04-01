require 'spec_helper'

describe 'mcollective' do
  context 'with defaults for all parameters' do
    it { should contain_class('mcollective') }
    it { should_not contain_class('mcollective::client') }
    it { should_not contain_class('mcollective::server') }
    it { should_not contain_class('mcollective::middleware') }
    it { should_not contain_class('mcollective::facts') }
  end

  context "On a RedHat OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it {
      should contain_package('mcollective').with( { 'name' => 'mcollective' } )
      should contain_service('mcollective').with( { 'name' => 'mcollective' } )
    }
  end

  context "On a Debian OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it {
      should contain_package('mcollective').with( { 'name' => 'mcollective' } )
      should contain_service('mcollective').with( { 'name' => 'mcollective' } )
    }
  end

  context "On a FreeBSD OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'FreeBSD'
      }
    end

    it {
      should contain_package('mcollective').with( { 'name' => 'sysutils/mcollective' } )
      should contain_service('mcollective').with( { 'name' => 'mcollectived' } )
    }
  end

  context "On an unknown OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end

  context "With a package name specified" do
    let :params do
      {
        :package_name => 'mcollective'
      }
    end

    it {
      should contain_package('mcollective').with( { 'name' => 'mcollective' } )
      should contain_service('mcollective').with( { 'name' => 'mcollective' } )
    }
  end
end
