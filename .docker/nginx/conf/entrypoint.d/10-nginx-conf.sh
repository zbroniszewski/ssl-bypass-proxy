#!/usr/bin/env bash

set -e

cat <<-EOF >/etc/nginx/nginx.conf
# Defines user and group credentials used by worker processes. If group
# is omitted, a group whose name equals that of user is used.
user nginx;

# Defines a file that will store the process ID of the main process.
pid /var/run/nginx.pid;

# Defines the number of worker processes. The optimal value depends on many factors,
# including (but not limited to) the number of CPU cores, the number of hard disk
# drives that store data, and load pattern. When one is in doubt, setting it
# to the number of available CPU cores would be a good start (the value
# "auto" will try to autodetect it).
worker_processes auto;

# Configures a timeout for a graceful shutdown of worker processes.
# When the time expires, nginx will try to close all the
# connections currently open to facilitate shutdown.
worker_shutdown_timeout 60;

# Configures logging. Several logs can be specified on the same configuration level (1.5.2).
# If on the main configuration level writing a log to a file is not explicitly defined,
# the default file will be used.
#
# The first parameter defines a file that will store the log. The special value stderr selects the
# standard error file. Logging to syslog can be configured by specifying the "syslog:" prefix.
# Logging to a cyclic memory buffer can be configured by specifying the "memory:" prefix and
# buffer size, and is generally used for debugging (1.7.11).
#
# The second parameter determines the level of logging, and can be one of the following: debug, info,
# notice, warn, error, crit, alert, or emerg. Log levels above are listed in the order of increasing
# severity. Setting a certain log level will cause all messages of the specified and more severe
# log levels to be logged. For example, the default level error will cause error, crit, alert,
# and emerg messages to be logged. If this parameter is omitted then error is used.
#
# For debug logging to work, nginx needs to be built with --with-debug.
#
# The directive can be specified on the stream level starting from version 1.7.11, and on the
# mail level starting from version 1.9.0.
error_log /var/log/nginx/error.log debug;

events {
  # Sets the maximum number of simultaneous connections that can be opened by a worker process.
  #
  # It should be kept in mind that this number includes all connections (e.g. connections with
  # proxied servers, among others), not only connections with clients. Another consideration
  # is that the actual number of simultaneous connections cannot exceed the current limit
  # on the maximum number of open files, which can be changed by worker_rlimit_nofile.
  worker_connections 512;
}


http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  access_log /var/log/nginx/access.log;

  upstream proxy {
    server ${PROXY_HOST}:443;
    keepalive_timeout 70;
  }

  include /etc/nginx/conf.d/*.conf;
}
EOF

exit 0
