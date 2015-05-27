##2015-05-27 - Release 0.1.6
###Added $logrotate_directory parameter

####Features
- Added rspec tests for platform defaults
- Added new $logrotate_directory variable

The new variable defaults to backwards compatible changes,
but allows it to be set to undef/nil to disable logrotate file installation.

##2015-05-26 - Release 0.1.5
###Added rspec tests

####Features
- Added rspec tests for every class

####Bugfixes
- Fix mistype in error message
- Remove extra spaces that puppet-lint didn't like
- Removed a set of double quotes without a variable inside
- Fixed dependency resolution problem

##2015-05-25 - Release 0.1.4
###Changed to BSD 3-Clause License

The module has been changed to the BSD 3-clause license.

####Features
- Added CHANGELOG in Markdown format

##2015-05-19 - Release 0.1.3
###Fixed problem with ActiveMQ config file template

####Bugfixes
- activemq won't replace variables inside the xml configuration without config.PropertyPlaceholderConfigurer

##2015-04-01 - Release 0.1.2
###Puppetlabs ActiveMQ 5.9 package, Improved facts.yaml generation

####Features
- Use ActiveMQ 5.9 package from Puppet Labs dependency repo
- Added module tests
- More complete metadata

####Bugfixes
- Revised facts.yaml generation to work properly regardless of Puppet stringify settings

##2014-09-10 - Release 0.1.1
###Improved documentation

##2014-07-14 - Release 0.0.1
###Original release
