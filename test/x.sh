#!/bin/bash
for var in "${!MOBIUS_@}"; do
    unset "$var"
done