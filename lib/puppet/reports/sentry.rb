require 'puppet'
require 'rubygems'
require 'raven'

Puppet::Reports.register_report(:sentry) do
    # Description
    desc = 'Puppet reporter designed to send failed runs to a sentry server'

    # Load the config else error
    config_path = File.join([File.dirname(Puppet.settings[:config]), "sentry.yaml"])

    unless File.exist?(config_path)
        raise(Puppet::ParseError, "Sentry config " + config_path + " doesn't exist")
    end

    config = YAML.load_file(config_path)

    # Check the config contains what we need
    unless config[:sentry_dsn]
        raise(Puppet::ParseError, "Sentry did not contain a dsn")
    end

    # Process an event
    def process
        # We only care if the run failed
        if self.status != 'failed'
            return
        end

        # Support environments
        if self.environment.nil?
            self.environment == 'production'
        end

        # Get the log entry
        log = self.logs.join('\n')

        # Configure raven
        Raven.configure do |raven_config|
            raven_config.dsn = config[:sentry_dsn]
            raven_config.current_environment = config.environment
        end

        # Send the data to sentry
        Raven.captureMessage(log)
    end
end
