#!/bin/bash

sudo unbound-control flush_zone .
resolvectl flush-caches
