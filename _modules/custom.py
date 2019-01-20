from __future__ import absolute_import, print_function, generators, unicode_literals
import re
from string import Template
from salt.exceptions import InvalidEntityError
from salt.ext import ipaddress, six

try:
    from collections import Mapping, Sequence
except ImportError:
    from collections.abc import Mapping, Sequence


def role_active(name):
    return role_data(name).get('managed', False)


def role_data(name, meta=None, max_depth=25):
    role = {}

    # Load metadata from fileserver if not given and merge into role dict
    if not isinstance(meta, Mapping):
        meta_file = 'salt://{0}/role.yaml'.format(name)
        meta = __salt__['slsutil.renderer'](meta_file).get(name, None)
        if meta is None:
            raise InvalidEntityError(
                'role metadata file [{0}] must contain top-level dictionary key with role name [{1}]'
                .format(meta_file, name))

    role = deep_merge(role, meta)

    # Recursively merge pillar data into role dict
    pillar_data = __salt__['pillar.get'](name, {})
    role = deep_merge(role, pillar_data)

    # Loop through role dict to process grain filters
    iterations = 0
    while iterations < max_depth:
        iterations = iterations + 1
        found = False

        for key, value in six.iteritems(role):
            # Skip pillar variable if value is not a mapping
            if not isinstance(value, Mapping):
                continue

            # Skip pillar variable if it does not match <[grain]>
            if not re.match(r'<[a-z0-9_]+>', key):
                continue

            # Construct grain name and lookup pillar overrides
            grain_filter = key[1:-1]
            grain_overrides = __salt__['pillar.get'](name + ':lookup', {})
            grain_data = __salt__['grains.filter_by'](
                value, grain=grain_filter, merge=grain_overrides)

            # Merge grain data into role dict and remove grain filter
            role = deep_merge(role, grain_data)
            role.pop(key, None)
            found = True

        if not found:
            break

    return role


def deep_merge(obj_a, obj_b):
    return __salt__['slsutil.merge'](obj_a, obj_b, strategy='recurse')


def dict_list_to_property_list(dict_list):
    properties = []

    for prop in dict_list:
        for key, value in six.iteritems(prop):
            properties.append({'key': key, 'value': value})

    return properties


def service_unit_instances(service_template):
    instances = []
    prefix = service_template + '@'

    for service in __salt__['service.get_running']():
        if len(service) > len(prefix) and service.startswith(prefix):
            instances.append(service[len(prefix):])

    return instances


def list_diff(list1, list2):
    return [x for x in list1 if x not in set(list2)]


def dict_list_diff(dict_list1, dict_list2):
    result = []

    for dict1 in dict_list1:
        for dict2 in dict_list2:
            if len([
                    key for key, value in six.iteritems(dict2)
                    if dict1.get(key, None) != value
            ]) == 0:
                break
        else:
            result.append(dict1)

    return result


def recursive_format(obj, **kwargs):
    if isinstance(obj, six.string_types):
        return obj.format(**kwargs)
    elif isinstance(obj, Mapping):
        return {
            k: recursive_format(v, **kwargs)
            for k, v in six.iteritems(obj)
        }
    elif isinstance(obj, Sequence):
        return [recursive_format(v, **kwargs) for v in obj]
    else:
        return obj


def default_network_address():
    _get_route = __salt__['network.get_route']
    _ip_addrs = __salt__['network.ip_addrs']
    _ip_addrs6 = __salt__['network.ip_addrs6']

    routes = __salt__['network.default_route']()
    routes = filter(lambda x: 'G' in x.get('flags', '').upper(), routes)
    routes = filter(lambda x: x.get('gateway', None), routes)

    gw_routes = map(lambda x: _get_route(x['gateway']), routes)
    gw_routes = filter(lambda x: x.get('source', None), gw_routes)
    addrs = map(lambda x: x['source'], gw_routes)

    if_addrs = map(lambda x: _ip_addrs(x['interface']), routes)
    if_addrs += map(lambda x: _ip_addrs6(x['interface']), routes)
    addrs += [addr for sublist in if_addrs for addr in sublist]

    addrs = map(lambda x: ipaddress.ip_address(x), addrs)
    addrs = filter(lambda x: not (x.is_loopback or x.is_link_local), addrs)
    addrs = filter(lambda x: not (x.is_reserved or x.is_unspecified), addrs)
    addrs = filter(lambda x: not x.is_multicast, addrs)

    addrs4 = filter(lambda x: isinstance(x, ipaddress.IPv4Address), addrs)
    addrs6 = filter(lambda x: isinstance(x, ipaddress.IPv6Address), addrs)

    return {
        'v4': addrs4[0].compressed if len(addrs4) > 0 else None,
        'v6': addrs6[0].compressed if len(addrs6) > 0 else None,
    }
