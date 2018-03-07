#!/bin/bash -e

api_key=$(docker-compose exec conjur rails r "print Credentials['demo-policy:user:admin'].api_key")

echo '--------- Install Summon, Summon-Conjur, and Ansible ------------'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key --entrypoint /bin/bash conjur_cli -c "
  curl -sSL https://raw.githubusercontent.com/cyberark/summon/sudoless-installer/install.sh | bash
  curl -sSL https://raw.githubusercontent.com/cyberark/summon-conjur/sudoless-installer/install.sh | bash
  apt-get update && apt-get install -y software-properties-common
  echo \"deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main\" >> /etc/apt/sources.list
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
  apt-get update && apt-get install -y ansible

  summon --yaml 'SSH_KEY: !var:file ansible/staging/foo/ssh_private_key' bash -c 'ansible-playbook -i \"localhost,\" -c local /src/ansible-demo/playbooks/git_checkout.yml'
"

summon --yaml 'SSH_KEY: !var:file ansible/staging/foo/ssh_private_key' bash -c 'ansible-playbook --private-key $SSH_KEY playbook/applications/foo.yml' 

# summon ansible-playbook -i "localhost," -c local /src/ansible-demo/git_checkout.yml

# echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list

# summon --yaml 'SSH_KEY: !var:file ansible/staging/foo/ssh_private_key' bash -c 'ansible-playbook -i "localhost," -c local /src/ansible-demo/playbooks/git_checkout.yml'
