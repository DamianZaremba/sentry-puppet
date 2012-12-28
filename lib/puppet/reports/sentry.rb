require 'puppet'
require 'yaml'

begin
    require 'rubygems'
rescue LoadError => e
    Puppet.err "You need `rubygems` to send reports to Sentry"
end

begin
    require 'raven'
rescue LoadError => e
    Puppet.err "You need the `raven-sentry` gem to send reports to Sentry"
end

Puppet::Reports.register_report(:sentry) do
    # Description
    desc = 'Puppet reporter designed to send failed runs to a sentry server'

    # Load the config else error
    config_path = File.join([File.dirname(Puppet.settings[:config]), "sentry.yaml"])

    unless File.exist?(config_path)
        raise(Puppet::ParseError, "Sentry config " + config_path + " doesn't exist")
    end

    CONFIG = YAML.load_file(config_path)

    # Process an event
    def process
        # We only care if the run failed
        if self.status != 'failed'
            return
        end

        # Check the config contains what we need
        if not CONFIG[:sentry_dsn]
            raise(Puppet::ParseError, "Sentry did not contain a dsn")
        end

         if self.respond_to?('environment')
             @environment = self.environment
         else
             @environment = 'production'
         end

        # Configure raven
        Raven.configure do |config|
            config.dsn = CONFIG[:sentry_dsn]
            config.current_environment = @environment
        end

        # Get the important looking stuff to sentry
        self.logs.each do |log|
            if log.level.to_s == 'err'
               options = {
                    'level' => log.level,
                    'abs_path' => log.file,
                    'lineno' => log.line,
                    'tags' => log.tags,
                }
                # This doesn't work, why? :(
                #Raven.captureMessage(log.message, options)

                msg = log.message + " at " + log.file + ":" + log.line.to_s
                Raven.captureMessage(msg)
            end
        end
    end
end
