ufw_allow_ssh:
  cmd.run:
    - name: ufw allow ssh
    - unless: ufw status | grep -q "22/tcp.*ALLOW"
    - require:
      - pkg : ufw
