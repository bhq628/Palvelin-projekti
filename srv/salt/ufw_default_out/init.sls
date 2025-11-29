ufw_default_out:
  cmd.run:
    - name: ufw default allow outgoing
    - unless: 'ufw status verbose | grep -q "Default: deny (incoming), allow (outgoing)"'
    - require:
      - cmd: ufw_enable
