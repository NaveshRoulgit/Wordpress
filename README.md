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

  v)Now, we will define different required roles in a 'Roles' sub-directory under a 'Project' directory:
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
                  
       x)We will add the following contents into project/roles/wordpress/tasks/main.yml
                  
                  ---
                  #tasks file for wordpress
                  - name: Download WordPress
                    get_url:
                        url=https://wordpress.org/latest.tar.gz
                        dest=/tmp/wordpress.tar.gz
                        validate_certs=no

                  - name: Extract WordPress
                    unarchive: src=/tmp/wordpress.tar.gz dest=/var/www/   copy=no
                    become: yes

                  - name: Update default Apache site
                    become: yes
                    lineinfile:
                        dest=/etc/apache2/sites-enabled/000-default.conf
                        regexp="(.)+DocumentRoot /var/www/html"
                        line="DocumentRoot /var/www/wordpress"
                        notify:
                          - restart apache

                  - name: Copy sample config file
                    command: mv /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php creates=/var/www/wordpress/wp-config.php
                    become: yes

                  - name: Update WordPress config file
                    lineinfile:
                        dest=/var/www/wordpress/wp-config.php
                        regexp="{{ item.regexp }}"
                        line="{{ item.line }}"
                    with_items:
                      - {'regexp': "define\\('DB_NAME', '(.)+'\\);", 'line': "define('DB_NAME', '{{wp_mysql_db}}');"}
                      - {'regexp': "define\\('DB_USER', '(.)+'\\);", 'line': "define('DB_USER', '{{wp_mysql_user}}');"}
                      - {'regexp': "define\\('DB_PASSWORD', '(.)+'\\);", 'line': "define('DB_PASSWORD', '{{wp_mysql_password}}');"}
                    become: yes

        xi)Finally, we will add the following snippet to project/roles/wordpress/handlers/main.yml to restart the apache
                  ---
                  # handlers file for wordpress
                  - name: restart apache
                    service: name=apache2 state=restarted
                    become: yes

        xii)Now, we will run the Ansible Playbook 'play.yml'
                  project>> ansible-playbook play.yml -i hosts -i ubuntu
                  
                  
        xiii)Then, put the Public IP of AWS instance in the Browser:
                  -The initial installation and congiguration page of WordPress opens
                  -Give the details of Site title, username, password, email and click on 'Install Wordpress'
                  -Login with the credentials again for the Web dashboard and the Website.
                  
          
       ## For Higher Availability we can create our own VPC(Virtual Private Cloud) network in AWS cloud and use the Elastic Load Balancer(ELB) service in AWS.
