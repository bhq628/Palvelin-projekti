ufw_enable:
  cmd.run:
    - name: 'ufw --force enable'
    - unless: 'ufw status | grep -q "Status: active"'
    - require:
      - pkg: ufw
