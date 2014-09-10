package "bind9"

service "bind9" do
  action :enable
end

template "/etc/bind/named.conf" do
  source "consul_named.conf.erb"
  user "bind"
  group "bind"
  notifies :restart, "service[bind9]"
end

template "/etc/bind/consul.conf" do
  user "bind"
  group "bind"
  notifies :restart, "service[bind9]"
end

template "/etc/dhcp/dhclient.conf" do
  source "consul_dhclient.conf.erb"
  notifies :run, "execute[kill dhclient]", :immediate
end

execute "kill dhclient" do
  command "pkill dhclient"
  notifies :run, "execute[start dhclient]", :immediate
  action :nothing
end

execute "start dhclient" do
  command "dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0"
  action :nothing
end

directory "/var/bind" do
  user "bind"
  group "bind"
  recursive true
  action :create
end
