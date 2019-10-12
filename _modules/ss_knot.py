# pylint: disable=missing-docstring,undefined-variable
from __future__ import absolute_import, print_function, generators, unicode_literals
import itertools
from copy import deepcopy
from salt.ext import six


def parse_pillar_zones(zones_pillar):
    zones = {}
    zone_mixins = {
        zone_name: zone.get('mixins', [])
        for zone_name, zone in six.iteritems(deepcopy(zones_pillar))
    }

    # Attempt to resolve all zone mixins
    deps_attempts = 25
    deps_pending = list(itertools.chain.from_iterable(zone_mixins.values()))
    while deps_attempts > 0 and len(deps_pending):
        zones_loaded = zones.keys()

        # Iterate through all declared zones and parse zone once all mixins are resolved
        for zone_name, mixins in six.iteritems(zone_mixins.copy()):
            zone_mixins[zone_name] = mixins = [
                mixin for mixin in mixins if mixin not in zones_loaded
            ]
            if len(mixins) == 0:
                zones[zone_name] = _parse_pillar_zone(zones_pillar, zone_name)

        # Remove zones which have been loaded
        for zone_name in zone_mixins.copy().keys():
            if zone_name in zones_loaded:
                del zone_mixins[zone_name]

        # Decrement the available attempts and update the list of pending dependencies
        deps_attempts -= 1
        deps_pending = list(itertools.chain.from_iterable(
            zone_mixins.values()))

    # Abort if not all mixins have been resolved
    if len(deps_pending) > 0:
        raise ValueError('unresolved pillar zonefile mixins: {0}'.format(
            ', '.join(deps_pending)))

    return zones


def _parse_pillar_zone(zones, zone_name):
    zone = zones[zone_name]
    zone_records = {}

    # Merge mixin records in given order
    for mixin in zone.get('mixins', []):
        records = zones[mixin].get('records', {})
        zone_records = __salt__['defaults.merge'](zone_records,
                                                  records,
                                                  merge_lists=True,
                                                  in_place=False)

    # Merge declared records into mixin records
    zone = __salt__['defaults.merge'](dict(records=zone_records),
                                      zone,
                                      merge_lists=True,
                                      in_place=False)

    # Return zone with merged records
    return zone
