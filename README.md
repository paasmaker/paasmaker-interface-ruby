Paasmaker Ruby Interface Library
================================

This is a simple Ruby library that is designed to read in the Paasmaker
configuration, falling back to a custom configuration file in development.

Usage
-----

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