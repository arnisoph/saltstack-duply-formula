#!jinja|yaml

{% from 'duply/defaults.yaml' import rawmap_osfam with context %}
{% set datamap = salt['grains.filter_by'](rawmap_osfam, merge=salt['pillar.get']('duply:lookup')) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

duply:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}

{% for k, v in datamap.profiles|default({})|dictsort if k != 'common' %}
  {% set prof_loc = v.profile_location|default('/root/.duply') %}

  {% set common_prof = datamap.profiles.common|default({}) %}
  {% set prof_settings = common_prof.conf|default({}) %}
  {% do prof_settings.update(v.conf) %}
  #  {{ v.conf }}


duply_profile_{{ k }}_parent_dir:
  file:
    - directory
    - name: {{ prof_loc }}
    - mode: 700
    - user: root
    - group: root

duply_profile_{{ k }}_dir:
  file:
    - {{ v.ensure|default('directory') }}
    - name: {{ prof_loc }}
    - name: {{ prof_loc }}/{{ k }}
    - mode: 700
    - user: root
    - group: root

{% if v.ensure|default('directory') != 'absent' %}

duply_profile_{{ k }}_conf:
  file:
    - managed
    - name: {{ prof_loc }}/{{ k }}/conf
    - source: {{ v.profile_template_path|default('salt://duply/files/profile_conf') }}
    - mode: 600
    - user: root
    - group: root
    - template: jinja
    - context:
      settings: {{ prof_settings }}
      dupl_params: {{ v.dupl_params|default([]) }}

duply_profile_{{ k }}_exclude:
  file:
    - managed
    - name: {{ prof_loc }}/{{ k }}/exclude
    - source: {{ v.exclude_template_path|default('salt://duply/files/exclude') }}
    - mode: 600
    - user: root
    - group: root
    - template: jinja
    - context:
      excludes: {{ v.excludes|default({}) }}

    {% if 'pre' in v %}
duply_profile_{{ k }}_pre_script:
  file:
    - managed
    - name: {{ prof_loc }}/{{ k }}/pre
    - source: {{ v.pre.pre_template_path|default('salt://duply/files/pre') }}
    - mode: 700
    - user: root
    - group: root
    - template: jinja
    {% endif %}

    {% if 'post' in v %}
duply_profile_{{ k }}_post_script:
  file:
    - managed
    - name: {{ prof_loc }}/{{ k }}/post
    - source: {{ v.post.pre_template_path|default('salt://duply/files/post') }}
    - mode: 700
    - user: root
    - group: root
    - template: jinja
    {% endif %}
  {% endif %}
{% endfor %}
