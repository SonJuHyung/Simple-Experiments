#!/bin/bash 

redis-cli config set stop-writes-on-bgsave-error no
redis-cli config set save ""
