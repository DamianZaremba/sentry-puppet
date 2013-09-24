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
    Puppet.err "You need the `raven-sentry` gem installed on the puppetmaster to send reports to Sentry"
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

         if self.respond_to?(:host)
             @host = self.host
         end

         if self.respond_to?(:kind)
             @kind = self.kind
         end
         if self.respond_to?(:puppet_version)
           @puppet_version = self.puppet_version
         end

         if self.respond_to?(:status)
           @status = self.status
         end

        # Configure raven
        Raven.configure do |config|
            config.dsn = CONFIG[:sentry_dsn]
            config.current_environment = @environment
        end

        # Get the important looking stuff to sentry
        self.logs.each do |log|
            if log.level.to_s == 'err'
                Raven.captureMessage(log.message + " at " + log.file + ":" + log.line.to_s, {
                  :server_name => @host,
                  :tags => {
                    'environment' => @environment,
                    'status'      => @status,
                    'version'     => @puppet_version,
                    'kind'        => @kind,
                  },
                  :extra => {
                    'source' => log.source,
                    'line'   => log.line.to_s,
                    'file'   => log.file,
                  },
                })
            end
        end
    end
end
