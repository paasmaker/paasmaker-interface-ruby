
# TODO: What Gem is required to make YAML work?
require 'yaml'
require 'json'

module Paasmaker

    # Exception raised when something goes wrong
    # with the interface. The message should indicate
    # what went wrong.
    class InterfaceException < Exception
    end

    # An interface class for Paasmaker. It can parse
    # the Paasmaker environment variables and supply them
    # to your application. Alternately, it can load override
    # configuration files to fill in missing values if it is
    # not running on Paasmaker.
    class Interface
        # Create a new instance of the interface class. Supply
        # an array of override path names. For example, supply
        # <tt>['../project-name.json']</tt> to load a configuration file
        # one level above your project root.
        def initialize(override_paths)
            @override_paths = override_paths
            @is_on_paasmaker = false
            @variables = {}
            @services = {}
            # It's over 9000.
            @port = 9001

            parse_metadata()
        end

        # Helper function to parse the Paasmaker metadata. You
        # should not call this externally.
        def parse_metadata() # :nodoc:
            raw_services = ENV['PM_SERVICES']
            raw_metadata = ENV['PM_METADATA']
            raw_port = ENV['PM_PORT']

            if raw_services and raw_metadata
                # We're running on Paasmaker.
                @is_on_paasmaker = true

                # Load from environment variables.
                @variables = JSON.parse(raw_metadata)
                @services = JSON.parse(raw_services)

                if raw_port
                    @port = raw_port.to_i()
                end
            else
                # Not running on Paasmaker, load from
                # a configuration file.
                load_configuration_file()
            end
        end

        # Helper function to find and load a configuration file.
        # You should not need to call this externally.
        def load_configuration_file() # :nodoc:
            @override_paths.each do |path|
                if File.exist?(path)

                    if path.end_with?('.yml')
                        # It's YAML, parse it as such.
                        data = YAML.load_file(path)
                    elsif path.end_with?('.json')
                        # It's JSON.
                        data = JSON.parse(IO.read(path))
                    end

                    store_configuration(path, data)
                    return
                end

            end

            # If we got here, we were not able to load any files.
            raise InterfaceException, "Unable to find any configuration files to load."
        end

        # Helper function to store a loaded configuration. You should
        # not call this externally.
        def store_configuration(path, data) # :nodoc:
            # Validate the data first, filling in some missing blanks.
            if not data.has_key?('services')
                data['services'] = {}
            end

            if not data.has_key?('workspace')
                data['workspace'] = {}
            end

            if not data.has_key?('node')
                data['node'] = {}
            end

            if not data.has_key?('application')
                raise InterfaceException, "You must have application data in your configuration file."
            end

            if data.has_key?('port')
                @port = data['port']
            end

            required_keys = ['name', 'version', 'workspace', 'workspace_stub']
            required_keys.each do |key|
                if not data['application'].has_key?(key)
                    raise InterfaceException, "Missing required key #{key} in application section."
                end
            end

            # Store it all away.
            @services = data['services']
            @variables = data
        end

        # Return true if the application is running on Paasmaker.
        def is_on_paasmaker?()
            return @is_on_paasmaker
        end

        # Get a named service from Paasmaker. Raises an InterfaceException
        # if there is no such service.
        def get_service(name)
            if @services.has_key?(name)
                return @services[name]
            else
                raise InterfaceException, "No such service #{name}."
            end
        end

        # Return all the services assigned to this application.
        def get_all_services()
            return @services
        end

        # Get the application name.
        def get_application_name()
            return @variables['application']['name']
        end

        # Get the application version.
        def get_application_version()
            return @variables['application']['version']
        end

        # Get the workspace name.
        def get_workspace_name()
            return @variables['application']['workspace']
        end

        # Get the workspace stub.
        def get_workspace_stub()
            return @variables['application']['workspace_stub']
        end

        # Get the node tags. Returns a Hash of the tags.
        def get_node_tags()
            return @variables['node']
        end

        # Get the workspace tags. Returns a Hash of the tags.
        def get_workspace_tags()
            return @variables['workspace']
        end

        # Get the port that you should be listening on.
        def get_port()
            return @port
        end
    end
end