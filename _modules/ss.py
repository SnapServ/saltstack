# pylint: disable=missing-docstring,undefined-variable
from __future__ import absolute_import, print_function, generators, unicode_literals
import re
from copy import deepcopy
from salt.ext import ipaddress, six


class Role(object):
    GRAIN_MATCHER_RE = re.compile(
        r'^<(?P<grain>[a-z0-9_]+)>$', flags=re.IGNORECASE)

    def __init__(self, name):
        self._name = name
        self._includes = ()
        self._dependencies = ()

        self._load_defaults()
        self._load_pillar()
        self._generate_vars()

    def add_include(self, sls_name):
        self._includes += ('.{0}'.format(sls_name), )

    def add_include_if(self, condition, *args, **kwargs):
        if condition:
            self.add_include(*args, **kwargs)

    def dependency(self, name):
        role = Role(name)
        if not role.managed:
            raise ValueError('Dependency role [{0}] is not managed'.format(
                role.name))

        self._dependencies += (role.name, )
        return '{0}/macros.sls'.format(role.name)

    def tpl_path(self, path=None):
        if path is None:
            return 'salt://{0}/files'.format(self.name)

        return 'salt://{0}/files/{1}'.format(self.name, path)

    def resource(self, *names):
        return 'R@{0}/{1}'.format(self.name, '/'.join(names))

    def _load_defaults(self):
        defaults_path = 'salt://{0}/role.yaml'.format(self.name)
        defaults_data = __salt__['slsutil.renderer'](defaults_path)

        if self.name not in defaults_data:
            raise ValueError(
                'Invalid role metadata [{0}], missing top-level dict key'.
                format(defaults_path))

        self._defaults = defaults_data.get(self.name, {})

    def _load_pillar(self):
        pillar_data = __salt__['pillar.get'](self.name, {})
        self._pillar = pillar_data

    def _generate_vars(self):
        vars_data = RecursiveMerger.merge(self._defaults, self._pillar)
        vars_data = self._process_grain_matchers(vars_data)
        self._vars = RecursiveMerger.sanitize(vars_data)

    def _process_grain_matchers(self, obj):
        result = {}

        for k, v in six.iteritems(obj):
            # Skip values which are not a dictionary
            if not isinstance(v, dict):
                result[k] = v
                continue

            # Skip keys which are not a grain matcher
            matcher = self.GRAIN_MATCHER_RE.match(k)
            if matcher is None:
                result[k] = self._process_grain_matchers(v)
                continue

            # Execute grain matcher using optional overrides from pillar
            matcher_overrides = __salt__['pillar.get'](
                key=self.name + ':lookup', default={})
            matcher_data = __salt__['grains.filter_by'](
                lookup_dict=v,
                grain=matcher.group('grain'),
                merge=matcher_overrides)

            # Recursively call this function on results and merge them
            matcher_data = self._process_grain_matchers(matcher_data)
            result = RecursiveMerger.merge(result, matcher_data)

        return result

    @property
    def name(self):
        return self._name

    @property
    def vars(self):
        return self._vars

    @property
    def includes(self):
        if not self.managed:
            return []

        includes = self._dependencies
        includes += self._includes if self._includes else ('.role', )
        return includes

    @property
    def managed(self):
        return self.vars.get('managed', False)


class RecursiveMerger(object):
    STRATEGIES = ('overwrite', 'remove', 'merge-first', 'merge-last')

    def __init__(self, initial_data):
        self._data = initial_data if initial_data else {}

    @classmethod
    def merge(cls,
              a,
              b,
              dict_strategy='merge-last',
              list_strategy='merge-last'):
        a, b = deepcopy(a), deepcopy(b)
        if isinstance(a, dict) and isinstance(b, dict):
            return cls._merge_dict(a, b, dict_strategy, list_strategy)
        elif isinstance(a, list) and isinstance(b, list):
            return cls._merge_list(a, b, list_strategy)
        else:
            return b

    @classmethod
    def sanitize(cls, obj):
        if isinstance(obj, dict):
            obj.pop('__', None)
            for k, v in six.iteritems(obj):
                obj[k] = cls.sanitize(v)
        elif isinstance(obj, list):
            obj = [x for x in obj if not (isinstance(x, dict) and '__' in x)]

        return obj

    @classmethod
    def _merge_dict(cls, a, b, default_strategy, default_list_strategy):
        # Fetch strategy from dictionary
        strategy = b.pop('__', default_strategy)
        if strategy not in cls.STRATEGIES:
            raise ValueError(
                'Invalid dict merging strategy [{0}], should be one of [{1}]'.
                format(strategy, cls.STRATEGIES))

        # Handle overwrite strategy by returning the new dict
        if strategy == 'overwrite':
            return cls.sanitize(b)

        for k, v in six.iteritems(b):
            if strategy == 'remove':
                a.pop(k, None)
            elif k in a and cls._is_compatible(a[k], v):
                # Swap a[k] and v when using merge-first strategy
                if strategy == 'merge-first':
                    a[k], v = cls.sanitize(v), a[k]

                # Merge k/v from b using current strategy
                if isinstance(v, dict):
                    a[k] = cls._merge_dict(a[k], v, default_strategy,
                                           default_list_strategy)
                elif isinstance(v, list):
                    a[k] = cls._merge_list(a[k], v, default_list_strategy)
                else:
                    a[k] = v
            else:
                a[k] = cls.sanitize(v) if k in a else v

        return a

    @classmethod
    def _merge_list(cls, a, b, default_strategy):
        # Set default strategy and start with empty buffer
        strategy, buffer = default_strategy, []

        # Try to fetch original strategy
        original_strategy = None
        if len(a) > 0 and isinstance(a[0], dict) and '__' in a[0]:
            original_strategy = a.pop(0)

        # Add stop marker to "b" and loop through all items
        b.append({'__': None})
        for item in b:
            # Append normal items to buffer
            if not (isinstance(item, dict) and '__' in item):
                buffer.append(item)
                continue

            # Apply buffer to "a" using previous strategy
            if strategy == 'overwrite':
                a = buffer
                original_strategy = {'__': 'overwrite'}
            elif strategy == 'remove':
                a = [x for x in a if x not in buffer]
            elif strategy == 'merge-first':
                a = buffer + a
            elif strategy == 'merge-last':
                a = a + buffer

            # Fetch new strategy and empty buffer
            strategy, buffer = item['__'] or strategy, []
            if strategy not in cls.STRATEGIES:
                raise ValueError(
                    'Invalid list merging strategy [{0}], should be one of [{1}]'
                    .format(strategy, cls.STRATEGIES))

        # Re-insert original strategy if available
        if original_strategy:
            a.insert(0, original_strategy)

        return a

    @classmethod
    def _is_compatible(cls, a, b):
        return (isinstance(a, dict) and isinstance(b, dict)) or (isinstance(
            a, list) and isinstance(b, list)) or (type(a) == type(b))


def role(*args, **kwargs):
    return Role(*args, **kwargs)


def merge_recursive(a, b, **kwargs):
    return RecursiveMerger.merge(a, b, **kwargs)


def format_recursive(obj, **kwargs):
    if isinstance(obj, six.string_types):
        return obj.format(**kwargs)
    elif isinstance(obj, dict):
        return {
            k: format_recursive(v, **kwargs)
            for k, v in six.iteritems(obj)
        }
    elif isinstance(obj, list):
        return [format_recursive(v, **kwargs) for v in obj]
    else:
        return obj


def parse_properties(obj):
    props = []
    obj = [obj] if isinstance(obj, dict) else obj
    for prop in obj:
        for key, value in six.iteritems(prop):
            props.append({'key': key, 'value': value})

    return props


def default_network_address():
    _get_route = __salt__['network.get_route']
    _ip_addrs = __salt__['network.ip_addrs']
    _ip_addrs6 = __salt__['network.ip_addrs6']

    # Get default routes
    routes = __salt__['network.default_route']()
    routes = filter(lambda x: 'G' in x.get('flags', '').upper(), routes)
    routes = filter(lambda x: x.get('gateway', None), routes)

    # Get gateway of default routes
    gw_routes = map(lambda x: _get_route(x['gateway']), routes)
    gw_routes = filter(lambda x: x.get('source', None), gw_routes)
    addrs = map(lambda x: x['source'], gw_routes)

    # Get interface of default gateways
    if_addrs = map(lambda x: _ip_addrs(x['interface']), routes)
    if_addrs += map(lambda x: _ip_addrs6(x['interface']), routes)
    addrs += [addr for sublist in if_addrs for addr in sublist]

    # Get public addresses of interfaces
    addrs = map(lambda x: ipaddress.ip_address(x), addrs)
    addrs = filter(lambda x: not (x.is_loopback or x.is_link_local), addrs)
    addrs = filter(lambda x: not (x.is_reserved or x.is_unspecified), addrs)
    addrs = filter(lambda x: not x.is_multicast, addrs)

    # Split addresses into IPv4 and IPv6
    addrs4 = filter(lambda x: isinstance(x, ipaddress.IPv4Address), addrs)
    addrs6 = filter(lambda x: isinstance(x, ipaddress.IPv6Address), addrs)
    addrs4, addrs6 = list(addrs4), list(addrs6)

    # Return compressed IPv4 and IPv6 address if found
    return {
        'v4': addrs4[0].compressed if len(addrs4) > 0 else None,
        'v6': addrs6[0].compressed if len(addrs6) > 0 else None,
    }
