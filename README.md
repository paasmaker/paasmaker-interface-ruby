Paasmaker Ruby Interface Library
================================

This is a simple Ruby library that is designed to read in the Paasmaker
configuration, falling back to a custom configuration file in development.

Usage - Rails
-------------

If you want to use this with your Rails project, do the following steps:

* Add paasmaker-interface to your Gemfile:

	gem 'paasmaker-interface'

* Update your database.yml file to look like the following:

	<% require 'paasmaker' %>
	<% interface = Paasmaker::Interface.new(['../project-configuration.yml']) %>
	<% database = interface.get_service('postgres') %>

	production:
	  adapter: postgresql
	  database: "<%= database['database'] %>"
	  host: "<%= database['hostname'] %>"
	  username: "<%= database['username'] %>"
	  password: "<%= database['password'] %>"
	  port: "<%= database['port'] %>"

  And update your adapter as appropriate for your application.

Usage - Other applications
--------------------------

To read in the configuration details in other applications, you can instantiate
the Interface class directly and work with it.

	require 'paasmaker'

	interface = Paasmaker::Interface.new(['../project-configuration.yml'])

	interface.is_on_paasmaker?()

	service = interface.get_service('service')

Example Configuration Overrides
-------------------------------

Example YAML configuration file:

	services:
	  parameters:
	    foo: bar

	application:
	  name: test
	  version: 1
	  workspace: Test
	  workspace_stub: test

Example JSON configuration file:

	{
		"services": {
			"parameters": {
				"foo": "bar"
			}
		},
		"application": {
			"name": "test",
			"version": 1,
			"workspace": "Test",
			"workspace_stub": "test"
		}
	}