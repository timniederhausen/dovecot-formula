{% from 'dovecot/map.jinja' import dovecot with context %}
{% from 'dovecot/macros.jinja' import sls_block, labels with context %}

{% for pkg in dovecot.packages %}
{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}

{% set files = [] %}

{% for name, values in dovecot.configs.items() %}
dovecot_conf_{{ name }}:
  file.managed:
    - name: {{ dovecot.config_dir }}/{{ name }}.conf
    - makedirs: true
    {{ sls_block(values) | indent(4) }}
{% do files.append('file: dovecot_conf_' + name) %}
{% endfor %}

{% for name, values in dovecot.dicts.items() %}
dovecot_dict_{{ name }}:
  file.managed:
    - name: {{ dovecot.config_dir }}/{{ name }}.conf.ext
    - makedirs: true
    {{ sls_block(values) | indent(4) }}
{% do files.append('file: dovecot_dict_' + name) %}
{% endfor %}

dovecot_service:
  service.running:
    - name: {{ dovecot.service }}
    - enable: {{ dovecot.service_enabled }}
    - watch:
      {{ labels(files) | indent(6) }}
