This is a Samba 4 server docker image, aims at setting up a smb share without messing up your server. Pull the image, mount a shared folder and you are ready to go.

Required arguments:

TZ: timezone
SMB_USER: user for accessing the samba share, which has the "admin" access
SMB_PASS: password for samba user
Usage:

example 1, using host network and exposing /media/movies folder. The smb config file is also exposed to /container_data/samba/config/smb.conf, which you can customize for your needs:
docker run -d --name samba --net=host -v /media/movies:/share -v /container_data/samba/config:/etc/samba yaurora/samba:latest
example 2, using bridge network and exposing ports 139, 445
docker run -d --name samba -p 139:139 -p 445:445 -v /media/movies:/share -v /container_data/samba/config:/etc/samba yaurora/samba:latest
example 3, using docker-compose
version: '3'
services:
  samba:
    image: yaurora/samba
    container_name: samba
    volumes:
      - /container_data/samba/config:/etc/samba
      - /container_data/media:/share
    environment:
      - TZ=Asia/Shanghai
      - SMB_USER=someuser
      - SMB_PASS=somePass
    ports:
      - 139:139
      - 445:445
    restart: always
Note that if you want to expose more than one share, you can costomize it in smb.conf, for instance, but make sure you added them to the volume binds. The docker-compose file will be something like below:

version: '3'
services:
  samba:
    image: yaurora/samba
    container_name: samba
    volumes:
      - /container_data/samba/config:/etc/samba
      - /some_folder/movies:/movies
      - /another_folder/tvseries:/tvseries
    environment:
      - TZ=Asia/Shanghai
      - SMB_USER=someuser
      - SMB_PASS=somePass
    ports:
      - 139:139
      - 445:445
    restart: always
then the smb config will be something like below, just make sure the path in each share matches the volumes you exposed above:

[global]
   map to guest = Bad User
   log file = /var/log/samba/%m
   log level = 10
   workgroup = WORKGROUP
   server role = standalone server
   usershare allow guests = no
[movies]
    comment = movies
    path = /movies
    read only = no
    browsable = yes
[tvseries]
    comment = tvseries
    path = /tvseries
    read only = no
    browsable = yes
test
e.g., on Windows machine mount the share with Windows explorer or the "net use" command:

net use X: \\192.168.1.100\media smb_pass /user:smb_user
or PowerShell if you would like to access it from PowerShell:

New-PSDrive -Name Y -PSProvider FileSystem -Root \\192.168.1.100\media -Description "Samba share on 192.168.1.100" -Scope global -Persist -Credential (Get-Credential)
At last, make sure you give correct permissions to the samba user you created on folders you exposed. If something went wrong with the access, you probably need to correct the permissions if necessary:

```shell docker exec -it samba /bin/bash chown -R SMB_USER: /share # replace SMB_USER with the username you created in your docker run commend, and replace the path with your own value
