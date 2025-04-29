#!/bin/bash
cat /proc/net/if_inet6 | gawk '
@include "join"
{
  if($5 == "01") {
    split($1, _, "[0-9a-f]{,4}", seps)
    print join(seps, 1, length(seps), ":")
  }
}'
