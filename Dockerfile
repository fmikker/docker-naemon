FROM cpuguy83/ubuntu
ENV NAEMON_HOME /opt/naemon
ENV NAEMON_USER naemon
ENV NAEMON_GROUP naemon
ENV NAEMON_CMDUSER naemon
ENV NAEMON_CMDGROUP naemon
ENV NAEMONADMIN_USER naemonadmin
ENV NAEMONADMIN_PASS naemon
ENV APACHE_RUN_USER naemon
ENV APACHE_RUN_GROUP naemon
ENV NAEMON_TIMEZONE UTC
ENV CYCLE_NOTIFICATIONS 0
ENV CYCLE_OFF_PAUSE 10
ENV CYCLE_ON_PAUSE 300

RUN rpm -Uvh "https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm"

RUN yum update
RUN yum install -y naemon

# TODO investigate possibility to use PolKit

RUN ( egrep -i  "^${NAEMON_GROUP}" /etc/group || groupadd $NAEMON_GROUP ) && ( egrep -i "^${NAEMON_CMDGROUP}" /etc/group || groupadd $NAEMON_CMDGROUP )
RUN ( id -u $NAEMON_USER || useradd --system $NAEMON_USER -g $NAEMON_GROUP -d $NAEMON_HOME ) && ( id -u $NAEMON_CMDUSER || useradd --system -d $NAEMON_HOME -g $NAEMON_CMDGROUP $NAEMON_CMDUSER )

ADD http://downloads.sourceforge.net/project/naemon/naemon-3.x/naemon-3.5.1/naemon-3.5.1.tar.gz?r=http%3A%2F%2Fwww.naemon.org%2Fdownload%2Fcore%2Fthanks%2F%3Ft%3D1398863696&ts=1398863718&use_mirror=superb-dca3 /tmp/naemon.tar.gz
RUN cd /tmp && tar -zxvf naemon.tar.gz && cd naemon  && ./configure --prefix=${NAEMON_HOME} --exec-prefix=${NAEMON_HOME} --enable-event-broker --with-naemon-command-user=${NAEMON_CMDUSER} --with-command-group=${NAEMON_CMDGROUP} --with-naemon-user=${NAEMON_USER} --with-naemon-group=${NAEMON_GROUP} && make all && make install && make install-config && make install-commandmode && cp sample-config/httpd.conf /etc/apache2/conf.d/naemon.conf
ADD http://www.naemon-plugins.org/download/naemon-plugins-1.5.tar.gz /tmp/
RUN cd /tmp && tar -zxvf naemon-plugins-1.5.tar.gz && cd naemon-plugins-1.5 && ./configure --prefix=${NAEMON_HOME} && make && make install

RUN sed -i.bak 's/.*\=www\-data//g' /etc/apache2/envvars
RUN export DOC_ROOT="DocumentRoot $(echo $NAEMON_HOME/share)"; sed -i "s,DocumentRoot.*,$DOC_ROOT," /etc/apache2/sites-enabled/000-default

RUN ln -s ${NAEMON_HOME}/bin/naemon /usr/local/bin/naemon && mkdir -p /usr/share/snmp/mibs && chmod 0755 /usr/share/snmp/mibs && touch /usr/share/snmp/mibs/.foo

RUN echo "use_timezone=$NAEMON_TIMEZONE" >> ${NAEMON_HOME}/etc/naemon.cfg && echo "SetEnv TZ \"${NAEMON_TIMEZONE}\"" >> /etc/apache2/conf.d/naemon.conf

RUN mkdir -p ${NAEMON_HOME}/etc/conf.d && mkdir -p ${NAEMON_HOME}/etc/monitor && ln -s /usr/share/snmp/mibs ${NAEMON_HOME}/libexec/mibs
RUN echo "cfg_dir=${NAEMON_HOME}/etc/conf.d" >> ${NAEMON_HOME}/etc/naemon.cfg
RUN echo "cfg_dir=${NAEMON_HOME}/etc/monitor" >> ${NAEMON_HOME}/etc/naemon.cfg
RUN download-mibs && echo "mibs +ALL" > /etc/snmp/snmp.conf

RUN sed -i 's,/bin/mail,/usr/bin/mail,' /opt/naemon/etc/objects/commands.cfg && \
  sed -i 's,/usr/usr,/usr,' /opt/naemon/etc/objects/commands.cfg
RUN cp /etc/services /var/spool/postfix/etc/

RUN mkdir -p /etc/sv/naemon && mkdir -p /etc/sv/apache && rm -rf /etc/sv/getty-5 && mkdir -p /etc/sv/postfix
ADD naemon.init /etc/sv/naemon/run
ADD apache.init /etc/sv/apache/run
ADD postfix.init /etc/sv/postfix/run
ADD postfix.stop /etc/sv/postfix/finish
ADD cycle_notifications.sh /usr/local/bin/cycle_notifications.sh

ADD start.sh /usr/local/bin/start_naemon

ENV APACHE_LOCK_DIR /var/run
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

VOLUME /opt/naemon/var
VOLUME /opt/naemon/etc
VOLUME /opt/naemon/libexec
VOLUME /var/log/apache2
VOLUME /usr/share/snmp/mibs

CMD ["/usr/local/bin/start_naemon"]
