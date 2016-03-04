#Set the base image
 FROM phusion/baseimage
#Set the locale settings for Ubuntu
 RUN locale-gen en_US.UTF-8
 ENV LANG       en_US.UTF-8
 ENV LC_ALL     en_US.UTF-8
#Setup necessary packages
 RUN apt-get update -y
 RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget
 RUN add-apt-repository -y ppa:ondrej/php5
 RUN apt-get update -y
#Install Apache and PHP
 RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes php5-cli  \
  php5-mysql php5-memcache php5-curl php5-gd php5-mcrypt apache2 drush libapache2-mod-php5
 RUN php5enmod mcrypt
 RUN a2enmod rewrite
#Use baseimage-docker's init system.
 CMD ["/sbin/my_init"]
#apache2 Environment Variables, and config settings
 ENV APACHE_RUN_USER www-data
 ENV APACHE_RUN_GROUP www-data
 ENV APACHE_LOG_DIR /var/log/apache2
 ENV APACHE_LOCK_DIR /var/lock/apache2
 #ENV APACHE_PID_FILE=/var/run/apache2.pid
#Copy the default vhost file.
 COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
#runit service files
 COPY ./apache2-run.sh /etc/service/http/run
#runit service permissions
 RUN chmod +x /etc/service/http/run
#Run the Apache2 service
 CMD service apache2 start && tail -F /var/log/apache2/error.log
#Enable SSH
 RUN rm -f /etc/service/sshd/down
 # Regenerate SSH host keys. baseimage-docker does not contain any, so you
 # have to do that yourself. You may also comment out this instruction; the
 # init system will auto-generate one during boot.
 RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
#Expose port 80 and 22
 EXPOSE 80 22
#Clean the apt
 RUN apt-get clean
 RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
