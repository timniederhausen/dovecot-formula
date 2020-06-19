{% from 'dovecot/map.jinja' import dovecot with context %}
{% from 'dovecot/macros.jinja' import sls_block, labels with context %}

dovecot_packages:
  pkg.installed:
    - pkgs: {{ dovecot.packages | json }}
    - watch_in:
      - service: dovecot_service
    - require_in:
      - service: dovecot_service

# Various configs

dovecot_local_config:
  file.managed:
    - name: {{ dovecot.config.root }}/{{ dovecot.config.local_name }}.conf
    - makedirs: true
    {{ sls_block(dovecot.config.local) | indent(4) }}
    - watch_in:
      - service: dovecot_service
    - require_in:
      - service: dovecot_service

{% for name, values in dovecot.config.mainexts.items() %}
dovecot_conf_{{ name }}:
  file.managed:
    - name: {{ dovecot.config.root }}/dovecot-{{ name }}.conf.ext
    - makedirs: true
    {{ sls_block(values) | indent(4) }}
    - watch_in:
      - service: dovecot_service
    - require_in:
      - service: dovecot_service
{% endfor %}

{% for name, values in dovecot.config.confd_entries.items() %}
dovecot_conf_{{ name }}:
  file.managed:
    - name: {{ dovecot.config.root }}/conf.d/{{ name }}.conf
    - makedirs: true
    {{ sls_block(values) | indent(4) }}
    - watch_in:
      - service: dovecot_service
    - require_in:
      - service: dovecot_service
{% endfor %}

{% for name, values in dovecot.config.confd_ext_entries.items() %}
dovecot_dict_{{ name }}:
  file.managed:
    - name: {{ dovecot.config.root }}/conf.d/{{ name }}.conf.ext
    - makedirs: true
    {{ sls_block(values) | indent(4) }}
    - watch_in:
      - service: dovecot_service
    - require_in:
      - service: dovecot_service
{% endfor %}

# TLS/SSL keys

{% for name, values in dovecot.ssl.certs.items() %}
{{ dovecot.ssl.cert_root }}/dovecot-{{ name }}.crt:
  file.managed:
    - user: root
    - group: {{ dovecot.root_group }}
    - mode: 444
    {{ sls_block(values) | indent(4) }}
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

{% for name, values in dovecot.ssl.privkeys.items() %}
{{ dovecot.ssl.key_root }}/dovecot-{{ name }}.key:
  file.managed:
    - user: root
    - group: {{ dovecot.root_group }}
    - mode: 400
    {{ sls_block(values) | indent(4) }}
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

dovecot_service:
  service.running:
    - name: {{ dovecot.service }}
    - enable: {{ dovecot.service_enabled }}
