#!/bin/sh

set -euo pipefail

exec tini /usr/local/bin/btc-rpc-proxy --conf /etc/btc_rpc_proxy.toml
