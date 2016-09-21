# nginx.ng.pkg
#
# Manages installation of nginx from pkg.

{% from 'nginx/ng/map.jinja' import nginx, sls_block with context %}

nginx_install:
  pkg.installed:
    {{ sls_block(nginx.package.opts) }}
    - name: {{ nginx.lookup.package }}

{% if salt['grains.get']('os_family') == 'Debian' %}
  {%- if nginx.install_from_repo %}
nginx-official-repo:
  pkgrepo:
    - managed
    - humanname: nginx apt repo
    - name: deb http://nginx.org/packages/{{ grains['os'].lower() }}/ {{ grains['oscodename'] }} nginx
    - file: /etc/apt/sources.list.d/nginx-official-{{ grains['oscodename'] }}.list
    - keyid: ABF5BD827BD9BF62
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: nginx
    - watch_in:
      - pkg: nginx
  {%- else %}
nginx_ppa_repo:
  pkgrepo:
    {%- if nginx.install_from_ppa %}
    - managed
    {%- else %}
    - absent
    {%- endif %}
    {% if salt['grains.get']('os') == 'Ubuntu' %}
    - ppa: nginx/{{ nginx.ppa_version }}
    {% else %}
    - name: deb http://ppa.launchpad.net/nginx/{{ nginx.ppa_version }}/ubuntu trusty main
    - keyid: C300EE8C
    - keyserver: keyserver.ubuntu.com
    {% endif %}
    - require_in:
      - pkg: nginx_install
    - watch_in:
      - pkg: nginx_install
  {%- endif %}
{% endif %}