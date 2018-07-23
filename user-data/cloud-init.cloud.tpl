#cloud-config
# vim:syntax=yaml
debug: True
hostname: ${set_hostname}
fqdn: ${set_hostname}

write_files:
- path: /tmp/disk-setup.sh
  permissions: '0755'
  content: |
    #!/bin/bash
    set -e
    set -x


    # For new builds, if the partition doesnt exist then create it. Add more if statemens if more devices need parted.
    if [[ $(file -s ${device}1) != *XFS* ]]; then
      echo 'Filesystem ${device}1 has not been created. Creating it now!'
      parted -s ${device} mklabel gpt -- mkpart primary xfs 0% 100%
      sleep 5
      mkfs -t xfs ${device}
    fi

    # Give some time for the FS to be created as xfs... Had an issue with this taking too long
    sleep 5

    # add to fstab if not there. Add more if statements if more fstab entries are needed.  
    if ! egrep "^${device}" /etc/fstab; then
      echo "${device} ${directory} xfs     defaults        0 0" | tee --append /etc/fstab > /dev/null
    fi

    # mount it 
    mount -a
  

runcmd:
  - set -x
  - set -e

  # EBS volume disk setup. Log the output to user directory so you can reference it on failure.
  - /tmp/disk-setup.sh >> /home/${user}/disk-setup.log
     
output: {all: '| tee -a /home/${user}/install.userdata.log'}