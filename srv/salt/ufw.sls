ufw:
  pkg.installed

ufw_enable:
  cmd.run:
    - name: 'ufw --force enable'
    - unless: 'ufw status verbose | grep -q "Status: active"'
    - require:
      - pkg: ufw

ufw_service:
  service.running:
    - name: ufw
    - enable: True
    - require:
      - pkg: ufw

ufw_default_in:
  cmd.run:
    - name: ufw default deny incoming
    - unless: 'ufw status verbose | grep -q "Default: deny (incoming)"'
    - require:
      - cmd: ufw_enable

ufw_default_out:
  cmd.run:
    - name: ufw default allow outgoing
    - unless: 'ufw status verbose | grep -q "Default: deny (incoming), allow (outgoing)"'
    - require:
      - cmd: ufw_enable
