sentry-puppet
=============
Puppet reporter designed to send failed runs to a sentry server

Dependencies
------------
* Puppet
* RubyGems
* sentry-raven Gem

Usage
-----
1. `yum install rubygems`
2. `gem install sentry-raven`
3. `git clone https://github.com/DamianZaremba/sentry-puppet.git /etc/puppet/<environment>/modules/sentry/`
4. `cp /etc/puppet/<environment>/modules/sentry/sentry.yaml /etc/puppet/<environment>/`
5. Add required configuration to Hiera:

        {"sentry": {"dsn": "SENTRY_DSN"}}

6. Enable pluginsync and reports:

        [master]
        report = true
        reports = store,sentry
        pluginsync = true

        [agent]
        report = true
        pluginsync = true

7. Do a puppet run

Screenshot
---------
![](https://github.com/DamianZaremba/sentry-puppet/raw/master/screenshot.png)

License
-------
Copyright 2012 Damian Zaremba

sentry-puppet is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

sentry-puppet is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with sentry-puppet.  If not, see <http://www.gnu.org/licenses/>.
