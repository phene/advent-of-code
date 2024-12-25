#!/usr/bin/env bash
TYPE=svg

dot -Kneato -T${TYPE} < graph-orig.dot > graph-orig.${TYPE}
dot -Kneato -T${TYPE} < graph-fixed.dot > graph-fixed.${TYPE}
