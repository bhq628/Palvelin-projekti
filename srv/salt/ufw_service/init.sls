ufw_service:
  service.running:
    - name: ufw
    - enable: True
    - require:
      - pkg: ufw
