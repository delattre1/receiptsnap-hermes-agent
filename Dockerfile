# Derived image for the Hermes Hackathon's Agent Index requirement: adds the
# usage reporter as a supervised service, on top of agent-mgr's own pinned
# local base -- otherwise unmodified. Built and run entirely locally via
# agent-mgr (see compose.override.yml); NOT the cloud-fleet Dockerfile
# pattern plow-pbc/life-assistant-hermes-agent uses for its own exe.dev VM
# deployment -- that targets a different image lineage
# (public.ecr.aws/.../plow-cloud-agents) with different conventions
# (HERMES_HOME=/var/lib/hermes, a fixed uid 10000). This one was built and
# verified against THIS repo's actual local base.
#
# BASE tracks agent.env's AGENT_IMAGE... in reverse: agent.env names the tag
# THIS Dockerfile produces (per agent-mgr's HOWTO "Where does my code go?"),
# so BASE's default here is the one place the upstream pin actually lives.
# Rebump: `agent-mgr resolve hermes-scaffold` after a stack.json bump, then
# update the default below and rebuild.
ARG BASE=nousresearch/hermes-agent@sha256:8f4e8677281eca188bc9d2fda90806646ba19941fce55fa8fda2d63112ff48a8
FROM ${BASE}

COPY LICENSE /usr/share/doc/hermes-scaffold/LICENSE

# The usage reporter, fetched at build from the commit vendor/client.pin
# names and checked against the hash beside it. Fetched rather than
# committed because plow-pbc/agent-index-client owns that file and is
# public; pinned rather than tracked from a branch because this runs inside
# an agent holding a live credential, and a moving reference would
# substitute unreviewed code under it.
#
# Root-owned under /opt/plow, outside every skill and outside $HERMES_HOME:
# everything under the mounted home is agent-writable, and scheduling a
# script living there would turn one prompt-injected turn that rewrites it
# into code the supervisor runs unattended, forever, holding this agent's
# chat credential.
COPY vendor/client.pin /opt/plow/agent-index-client.pin
RUN set -eu; \
    sha="$(sed -n 's/^sha=//p' /opt/plow/agent-index-client.pin)"; \
    want="$(sed -n 's/^sha256=//p' /opt/plow/agent-index-client.pin)"; \
    path="$(sed -n 's/^path=//p' /opt/plow/agent-index-client.pin)"; \
    curl -fsS --max-time 60 -o /opt/plow/agent-index-client.py \
      "https://raw.githubusercontent.com/plow-pbc/agent-index-client/${sha}/${path}"; \
    got="$(sha256sum /opt/plow/agent-index-client.py | cut -d' ' -f1)"; \
    [ "$got" = "$want" ] || { echo "agent-index client is $got, pin says $want" >&2; exit 1; }; \
    chown root:root /opt/plow/agent-index-client.pin /opt/plow/agent-index-client.py; \
    chmod 0644 /opt/plow/agent-index-client.py

# The reporter's schedule, as a supervised service beside the gateway,
# registered into the base image's own (empty) user2 extension bundle rather
# than its user bundle -- so a future base rebuild that adds services of its
# own cannot collide with this repo's registration of them.
COPY image/s6-overlay/ /etc/s6-overlay/
RUN chmod 0755 /etc/s6-overlay/s6-rc.d/agent-index/run
