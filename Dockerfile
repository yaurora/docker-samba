FROM ubuntu:latest
ARG SMB_USER
ARG SMB_PASS
ENV SMB_USER=$SMB_USER
ENV SMB_PASS=$SMB_PASS
ENV TZ=Asia/Shanghai

RUN apt update -yqq
RUN apt install -yqq --no-install-recommends samba ca-certificates openssl tzdata
RUN echo $TZ | tee /etc/timezone
RUN useradd $SMB_USER -M --password $(openssl passwd -1 -salt $(openssl rand -hex 8) $SMB_PASS)
RUN  (echo ${SMB_PASS}; echo ${SMB_PASS}) |smbpasswd -L -D 3 -a -s ${SMB_USER}
COPY smb.conf /etc/samba/smb.conf
EXPOSE 139/tcp 445/tcp

#CMD ["smbd", "--foreground", "--log-stdout", "--no-process-group"]
#CMD ["smbd", "-F", "-S",  "-d 3", "-s /srv/smb.conf"]
CMD /usr/sbin/smbd --daemon --foreground --no-process-group --log-stdout --debuglevel=3 --configfile=/etc/samba/smb.conf
