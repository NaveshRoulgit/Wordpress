Assumptions:
An AWS account running Ubuntu on 2 EC2 Instances
  i) First Instance acting as SERVER having Ansible installed
 ii) Second Instance acting as CLIENT

Stepwise Process:
 i)In both the Instances, an Ansible user is created and given SUDO Privilege
 ii)SSH connection is established between the Server and Client users (through SSH-keygen)
 -Connection checked by >>ssh ansible@<Public IP of Client>
 
 iii)In the 'hosts' file of SERVER we will add the CLIENT IP address where Wordpress will be installed:
      root>>cd /etc/ansible
          >>vi hosts
                
                 [webapp]
                <Public IP of CLIENT>
     
 iv)We will check the connectivity between Ansible SERVER and CLIENT
      >>ansible -m ping all
      If O/P is "Ping":"Pong" means its connected

  v)Now, we will define different required roles in a 'Roles' sub-directoryunder a 'Project' directory:
      >>mkdir project
      >>cd project
      >>mkdir roles
      >>cd roles
      >>ansible-galaxy init server
      >>ansible-galaxy init php
      >>ansible-galaxy init mysql
      >>ansible-galaxy init wordpress
                   
   vi)Put all these under a playbook 'play.yml'
            roles>> cd ..
            project>> vi play.yml
                   
                   - hosts: all
                     gather_facts: False

                    tasks:
                     - name: install python 
                       raw: test -e /usr/bin/python || (apt -y update && apt  install -y                       python-minimal)

                  - hosts: wordpress

                    roles:
                      - server
                      - php
                      - mysql
                      - wordpress
                   
           //Now the roles will run on the server which is under group Wordpress in Hosts inventory file and Python is installed onto all target servers
                   
    vii)We will add the following contents into project/roles/server/tasks/main.yml for installing some packages
                   
                   ---
                   # tasks file for server
                   - name: Update apt cache
                     apt: update_cache=yes cache_valid_time=3600
                     become: yes

                   - name: Install required software
                     apt: name={{ item }} state=present
                     become: yes
                     with_items:
                         - apache2
                         - mysql-server
                         - php7.2-mysql
                         - php7.2
                         - libapache2-mod-php7.2  
                         - python-mysqldb

   viii)We will add the following contents into project/roles/php/tasks/main.yml to install certain PHP extensions
                   
                   ---
                   # tasks file for php
                   - name: Install php extensions
                     apt: name={{ item }} state=present
                     become: yes
                     with_items:
                         - php7.2-gd
                         - php7.2-ssh2
                  
   ix)We will add the following contents into project/roles/mysql/defaults/main.yml to set variables
                   ---
                   # defaults file for mysql
                   wp_mysql_db: wordpress
                   wp_mysql_user: wordpress
                   wp_mysql_password: randompassword
                   
        Now inside project/roles/mysql/tasks/main.yml
                   ---
                   # tasks file for mysql
                   - name: Create mysql database
                     mysql_db: name={{ wp_mysql_db }} state=present
                     become: yes

                   - name: Create mysql user
                     mysql_user:
                           name={{ wp_mysql_user }}
                           password={{ wp_mysql_password }}
                           priv=*.*:ALL
                     become: yes


