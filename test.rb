#!/usr/bin/env ruby

require "./paasmaker/interface.rb"
require "test/unit"
require "json"

class TestPaasmakerInterface < Test::Unit::TestCase # :nodoc:
    def teardown()
        # Clean up for next time.
        ENV.delete('PM_SERVICES')
        ENV.delete('PM_METADATA')
        ENV.delete('PM_PORT')
    end

    def test_simple()
        # Give the class no configuration paths.
        begin
            interface = Paasmaker::Interface.new([])
            assert(false, "Should have raised exception.")
        rescue Paasmaker::InterfaceException
            assert(true, "Raised exception as expected.")
        end

        # And now a path that doesn't exist.
        begin
            interface = Paasmaker::Interface.new(['configs/noexist.yml'])
            assert(false, "Should have raised exception.")
        rescue Paasmaker::InterfaceException
            assert(true, "Raised exception as expected.")
        end

        # Now one that doesn't exist and one that does.
        interface = Paasmaker::Interface.new(['configs/noexist.yml', 'configs/test.yml'])

        assert_equal(interface.get_port(), 9002, "Port was not as expected.")
    end

    def test_json_config()
        # Test the JSON config loader.
        interface = Paasmaker::Interface.new(['configs/test.json'])
        confirm_test_configuration(interface)
    end

    def test_yml_config()
        # Test the YAML config loader.
        interface = Paasmaker::Interface.new(['configs/test.yml'])
        confirm_test_configuration(interface)
    end

    def test_invalid_config()
        # Test two invalid configuration files.
        begin
            interface = Paasmaker::Interface.new(['configs/invalid.yml'])
            assert(false, "Should have raised exception.")
        rescue Paasmaker::InterfaceException
            assert(true, "Raised exception as expected.")
        end

        begin
            interface = Paasmaker::Interface.new(['configs/invalid2.yml'])
            assert(false, "Should have raised exception.")
        rescue Paasmaker::InterfaceException
            assert(true, "Raised exception as expected.")
        end
    end

    def test_tags()
        # Test the workspace and node tags from the configuration file.
        interface = Paasmaker::Interface.new(['configs/tags.yml'])

        workspace_tags = interface.get_workspace_tags()
        node_tags = interface.get_node_tags()

        assert(workspace_tags.has_key?('tag'))
        assert(node_tags.has_key?('tag'))
    end

    def test_paasmaker_config()
        # Test configuration as if it was running on Paasmaker.
        services_raw = {'variables' => {'one' => 'two'}}
        metadata_raw = {
            'application' => {
                'name' => 'test',
                'version' => 1,
                'workspace' => 'Test',
                'workspace_stub' => 'test'
            },
            'node' => {'one' => 'two'},
            'workspace' => {'three' => 'four'}
        }

        ENV['PM_SERVICES'] = JSON.generate(services_raw)
        ENV['PM_METADATA'] = JSON.generate(metadata_raw)
        ENV['PM_PORT'] = "42600"

        interface = Paasmaker::Interface.new([])

        assert(interface.is_on_paasmaker?())
        assert_equal(interface.get_application_name(), "test")
        assert_equal(interface.get_application_version(), 1)
        assert_equal(interface.get_workspace_name(), "Test")
        assert_equal(interface.get_workspace_stub(), "test")

        workspace_tags = interface.get_workspace_tags()
        node_tags = interface.get_node_tags()
        assert(workspace_tags.has_key?('three'))
        assert(node_tags.has_key?('one'))

        service = interface.get_service('variables')
        assert(service.has_key?('one'))
        assert_equal(interface.get_port(), 42600)

        begin
            interface.get_service('no-service')
            assert(false, "Should have thrown exception.")
        rescue Paasmaker::InterfaceException
            assert(true, "Correctly raised exception.")
        end
    end

    def confirm_test_configuration(interface)
        # Helper function to confirm the test config files are correct.
        assert(false == interface.is_on_paasmaker?(), "Should not think it's on Paasmaker.")
        assert_equal(interface.get_application_name(), "test")
        assert_equal(interface.get_application_version(), 1)
        assert_equal(interface.get_workspace_name(), "Test")
        assert_equal(interface.get_workspace_stub(), "test")
        assert_equal(interface.get_workspace_tags().length, 0)
        assert_equal(interface.get_node_tags().length, 0)
        assert_equal(interface.get_all_services().length, 1)

        service = interface.get_service('parameters')
        assert(service.has_key?('foo'))

        begin
            interface.get_service('no-service')
            assert(false, "Should have thrown exception.")
        rescue Paasmaker::InterfaceException
            assert(true, "Correctly raised exception.")
        end
    end
end