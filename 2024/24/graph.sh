#!/usr/bin/env bash
TYPE=svg

dot -Kneato -T${TYPE} < graph.dot > graph.${TYPE}
