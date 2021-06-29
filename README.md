#Assumptions:
a)An AWS account running Ubuntu on 2 EC2 Instances
   i) First Instance acting as SERVER having Ansible installed
  ii) Second Instance acting as CLIENT
 
 -In both the Instances, an Ansible user is created and given SUDO Privilege
 -SSH connection is established between the Server and Client users (through SSH-keygen)
 -Connection checked by >>ssh ansible@<Public IP of Client>
 
 b)In the 'hosts' file of SERVER we will add the CLIENT IP address where Wordpress will be installed:
  root>>cd /etc/ansible
      >>vi hosts
  
    [webapp]
    <Public IP of CLIENT>
      
  c)Now, we will check the connectivity between Ansible SERVER and CLIENT
      >>ansible -m ping all
      If O/P is "Ping":"Pong" means its connected

