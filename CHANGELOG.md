## 2015-11-26 - Release 1.0.3
### Bugfix 
- Ensure that facts cronjob is moved into place without confirmation prompt 

##2015-11-26 - Release 1.0.2
###Bugfix release

####Bugfixes
- Fixed jetty password template variable reference (reported by devoncustard)

##2015-11-22 - Release 1.0.1
###Stable release

This release is in use in many production sites and is stable. 
Only non-breaking bugfixes will be applied to 1.0.X versions going forward.

Release 2.0 and above will only support Puppet 4 / future parser, 
and will drop support for Puppet 3 and below. 

####Bugfixes
- Fixed an error about referencing qualified variable in an optional class
- Added/improved docs in both README and facts::cronjobs class
- Fix for trailing comma on collectives (provided by Vadym Chepkov)
- Fix for wrong variable name on client plugin loglevel (provided by Vadym Chepkov)
- Fix for actionpolicy default name (reported by Taejon Moon) 

##2015-09-08 - Release 0.1.7
###Puppet 4 Compatibility

####Features
- Adjusted configuration to work with Puppet 4
- Added new `mcollective::facts::cronjob::run_every` parameter to control facts updates

####Obsoletes
The Hiera parameter 'mcollective::facts::cronjob::run_every' is now preferred
and the only working method for Puppet 4. Use of the 'mcollective::facts' class
is deprecated and will be removed in v1.0

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
