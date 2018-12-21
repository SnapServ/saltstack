from __future__ import absolute_import, print_function, generators, unicode_literals
import re
from salt.exceptions import InvalidEntityError
from salt.ext import six

try:
    from collections import Mapping
except ImportError:
    from collections.abc import Mapping


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

    role = deepmerge(role, meta)

    # Recursively merge pillar data into role dict
    pillar_data = __salt__['pillar.get'](name, {})
    role = deepmerge(role, pillar_data)

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
            role = deepmerge(role, grain_data)
            role.pop(key, None)
            found = True

        if not found:
            break

    return role


def deepmerge(obj_a, obj_b):
    return __salt__['slsutil.merge'](obj_a, obj_b, strategy='recurse')


def get_service_instances(service_template):
    instances = []
    prefix = service_template + '@'

    for service in __salt__['service.get_running']():
        if len(service) > len(prefix) and service.startswith(prefix):
            instances.append(service[len(prefix):])

    return instances
