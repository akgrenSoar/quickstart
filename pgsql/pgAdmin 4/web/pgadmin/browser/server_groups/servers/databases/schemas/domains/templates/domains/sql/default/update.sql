{% import 'macros/schemas/security.macros' as SECLABEL %}
{% if data %}
{% set name = o_data.name %}
{% if data.name %}
{% if data.name != o_data.name %}
ALTER TYPE {{ conn|qtIdent(o_data.basensp, o_data.name) }}
    RENAME TO {{ conn|qtIdent(data.name) }};
{% set name = data.name %}
{% endif %}
{% endif -%}
{% if data.typnotnull and not o_data.typnotnull %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    SET NOT NULL;
{% elif 'typnotnull' in data and not data.typnotnull and o_data.typnotnull%}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    DROP NOT NULL;
{% endif -%}{% if data.typdefault %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    SET DEFAULT {{ data.typdefault }};
{% elif data.typdefault == '' and o_data.typdefault %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    DROP DEFAULT;
{% endif -%}{% if data.owner %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    OWNER TO {{ conn|qtIdent(data.owner) }};
{% endif -%}{% if data.constraints %}
{% for c in data.constraints.deleted %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    DROP CONSTRAINT {{ conn|qtIdent(c.conname) }};
{% endfor -%}
{% for c in data.constraints.added %}
{% if c.conname and c.consrc %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    ADD CONSTRAINT {{ conn|qtIdent(c.conname) }} CHECK ({{ c.consrc }} );{% endif -%}
{% endfor -%}{% endif -%}
{% set seclabels = data.seclabels %}
{% if 'deleted' in seclabels and seclabels.deleted|length > 0 %}
{% for r in seclabels.deleted %}
{{ SECLABEL.UNSET(conn, 'DOMAIN', name, r.provider, o_data.basensp) }}

{% endfor -%}
{% endif %}
{% if 'added' in seclabels and seclabels.added|length > 0 %}
{% for r in seclabels.added %}
{{ SECLABEL.SET(conn, 'DOMAIN', name, r.provider, r.label, o_data.basensp) }}

{% endfor -%}
{% endif %}
{% if 'changed' in seclabels and seclabels.changed|length > 0 %}
{% for r in seclabels.changed %}
{{ SECLABEL.SET(conn, 'DOMAIN', name, r.provider, r.label, o_data.basensp) }}

{% endfor -%}
{% endif -%}{% if data.description is defined and data.description != o_data.description %}

COMMENT ON DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    IS {{ data.description|qtLiteral }};
{% endif -%}{% if data.basensp %}

ALTER DOMAIN {{ conn|qtIdent(o_data.basensp, name) }}
    SET SCHEMA {{ conn|qtIdent(data.basensp) }};{% endif -%}
{% endif -%}
