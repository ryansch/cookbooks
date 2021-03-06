include_recipe "rs_sandbox::default"

require 'socket'
rest_connection_version="0.0.15"

load_ruby_gem_into_rs_sandbox("i18n", nil, nil, true)
load_ruby_gem_into_rs_sandbox("rest_connection", rest_connection_version, nil, false)

d = directory value_for_platform("windows" => {"default" => "#{node[:rs_sandbox][:rl_user_home_dir]}/.rest_connection"}, "default" => "/etc/rest_connection") do
  recursive true
  action :nothing
end

d.run_action(:create)

t = template value_for_platform("windows" => {"default" => "#{node[:rs_sandbox][:rl_user_home_dir]}/.rest_connection/rest_api_config.yaml"}, "default" => "/etc/rest_connection/rest_api_config.yaml") do
  source "rest_api_config.yaml.erb"
  variables(
    :rest_pass => node[:utils][:rest_pass],
    :rest_user => node[:utils][:rest_user],
    :rest_acct_num => node[:utils][:rest_acct_num]
  )
  action :nothing
end

t.run_action(:create)

# A useful way to find "this" instance when running scripts that use rest_connection
# Tag.search('ec2_instance', ["ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"])
right_link_tag "ipv4:private=#{IPSocket.getaddress(Socket.gethostname)}"