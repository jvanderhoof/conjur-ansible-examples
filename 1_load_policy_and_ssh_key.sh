#!/bin/bash -e

api_key=$(docker-compose exec conjur rails r "print Credentials['demo-policy:user:admin'].api_key")

echo '--------- Load Conjur Policy ------------'
docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key --entrypoint /bin/bash conjur_cli -c "
  conjur policy load --replace root /src/policy/ansible.yml
"

docker-compose run --rm -e CONJUR_AUTHN_API_KEY=$api_key --entrypoint /bin/bash conjur_cli -c "
  conjur variable values add ansible/staging/foo/ssh_private_key \"$(cat ssh_keys/github_rsa)\"
"
