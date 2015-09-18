$:.unshift '../lib/puppet/util/network_device/netapp/'
require File.dirname(__FILE__) + '/../lib/puppet/util/network_device/netapp/NaServer'

def print_usage
  print ("Usage: netapp_conn_check.rb <storage_system> <user> \n")
  print ("<storage> -- storage_system\n")
  print ("<user> -- User name\n")
  print ("<password> -- Password, can also be environment var 'PASSWORD'\n")
  exit
end

def is_ip_e0m(ip_address,transport)
  retval=false
  # Get the network config
  result = transport.invoke("net-ifconfig-get")
  # Create an empty array to hold interface list
  interfaces = []
  interface_ips = []
  # Create an empty hash to hold interface_config
  interface_config = {}

  # Get an array of interfaces
  ifconfig = result.child_get("interface-config-info")
  ifconfig = ifconfig.children_get()
  # Itterate over interfaces
  ifconfig.each do |iface|
    iface_name = iface.child_get_string("interface-name")

    # Need to dig deeper to get IP address'
    iface_ips = iface.child_get("v4-primary-address")
    if iface_ips
      iface_ips = iface_ips.child_get("ip-address-info")
      iface_ip = iface_ips.child_get_string("address")
    end

    # Populate interface_config
    interface_config["ipaddress_#{iface_name}"] = iface_ip if iface_ip
  end
  if interface_config['ipaddress_e0M'] == ip_address
    retval=true
  end
  retval
end

args = ARGV.length
password = ENV['PASSWORD'] || ARGV[2]
if !password
  print_usage
end
if(args < 2)
  print_usage
end

storage = ARGV[0]
user = ARGV[1]
failure_exit_code = 1
success_exit_code = 0
retval = failure_exit_code

s = NaServer.new(storage, 1, 1)
s.set_server_type("Filer")
s.set_admin_user(user, password)
s.set_transport_type("HTTPS")
s.set_timeout(1)
output = s.invoke("system-get-version")

if(output.results_errno() != 0)
  r = output.results_reason()
  print("Failed : \n" + r)
else
  # Check if the passed-in IP address is e0M or not
  if !is_ip_e0m(storage,s)
    print("Failed :  Input IP is not of e0M\n")
  else
    r = output.child_get_string("version")
    print ("Version is : " + r + "\n")
    retval = success_exit_code
  end
end

exit retval
