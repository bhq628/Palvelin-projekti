ufw_default_in:
  cmd.run:
    - name: ufw default deny incoming
    - unless: 'ufw status verbose | grep -q "Default: deny (incoming)"'
    - require:
      - cmd: ufw_enable
