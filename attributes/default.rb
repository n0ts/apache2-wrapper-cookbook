#
# Cookbook Name:: apache2-wrapper
# Attribute:: default
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

include_attribute 'apache2::default'

default['apache2-wrapper'] = {
  'cronolog' => '/usr/sbin/cronolog',
  'mod_log_rotate' => {
    'interval' => 86400,
  },
  'prefork' => {
    'start_servers' => 10,
    'min_spare_servers' => 10,
    'max_spare_servers' => 10,
    'max_clients' => 10,
    'max_requests_per_child' => 0,
  },
  'worker' => {
    'server_limit' => 2,
    'thread_limit' => 10,
    'threads_per_child' => 10,
    'max_clients' => 20,
    'min_spare_threads' => 20,
    'max_spare_threads' => 20,
    'max_requests_per_child' => 0,
  },
}
