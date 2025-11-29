ufw_enable:
  cmd.run:
    - name: 'ufw enable --force enable'
    - unless: 'ufw status | grep -q "Status: active"'
    - require:
      - pkg: ufw
