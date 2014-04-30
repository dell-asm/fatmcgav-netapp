$:.unshift '../lib/puppet/util/network_device/netapp/'
require 'NaServer'

def print_usage
  print ("Usage: netapp_conn_check.rb <storage_system> <user> <password> \n")
  print ("<storage> -- storage_system\n")
  print ("<user> -- User name\n")
  print ("<password> -- Password\n")
  exit
end

args = ARGV.length
if(args < 3)
  print_usage
end

storage = ARGV[0]
user = ARGV[1]
password = ARGV[2]
failure_exit_code = 1
success_exit_code = 1
retval = failure_exit_code

s = NaServer.new(storage, 1, 1)
s.set_server_type("Filer")
s.set_admin_user(user, password)
s.set_transport_type("HTTP")
s.set_timeout(1)
output = s.invoke("system-get-version")

if(output.results_errno() != 0)
  r = output.results_reason()
  print("Failed : \n" + r)
else
  r = output.child_get_string("version")
  print ("Version is : " + r + "\n")
  retval = success_exit_code
end

exit retval
