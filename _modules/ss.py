# pylint: disable=missing-docstring,undefined-variable
from __future__ import absolute_import, print_function, generators, unicode_literals
from salt.ext import six


class LuaSerializer(object):
    LUA_STRING_DELIMITERS = [('[{}['.format('=' * n), ']{}]'.format('=' * n))
                             for n in range(10)]

    @classmethod
    def serialize(cls, value):
        if cls._type_of(value, int, float):
            return '{}'.format(value)
        elif cls._type_of(value, str):
            delim_open, delim_close = cls._get_string_delimiter(value)
            return '{}{}{}'.format(delim_open, value, delim_close)
        elif cls._type_of(value, list, tuple, set):
            value_dict = {k + 1: v for k, v in enumerate(value)}
            return cls.serialize(value_dict)
        elif cls._type_of(value, dict):
            item_lines = []
            for k, v in value.items():
                k, v = cls._build_dict_key(k), cls.serialize(v)
                item_lines.append('{} = {}'.format(k, v))

            if item_lines:
                return '{{\n{}\n}}'.format(
                    cls._indent(',\n'.join(item_lines), 1))
            else:
                return '{}'

        return cls.serialize(str(value))

    @staticmethod
    def _indent(string, level):
        delim = ' ' * level * 2
        return delim + ('\n' + delim).join(string.split('\n'))

    @staticmethod
    def _type_of(value, *types):
        return any(isinstance(value, t) for t in types)

    @classmethod
    def _build_dict_key(cls, key):
        key = str(cls.serialize(key))
        key_fmt = '[ {} ]' if key.startswith('[') else '[{}]'
        return key_fmt.format(key)

    @classmethod
    def _get_string_delimiter(cls, value):
        if '"' not in value and '\n' not in value:
            return '"', '"'
        for delim_open, delim_close in cls.LUA_STRING_DELIMITERS:
            if delim_open not in value and delim_close not in value:
                return delim_open, delim_close


def dict_strip_none(obj):
    return dict((k, v) for k, v in six.iteritems(obj)
                if k is not None and v is not None)


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


def parse_properties_list(obj):
    props = []
    obj = [obj] if isinstance(obj, dict) else obj
    for prop in obj:
        for key, value in six.iteritems(prop):
            props.append({'key': key, 'value': value})

    return props


def serialize_lua(value):
    return LuaSerializer.serialize(value)


def systemd_service_instances(service_template):
    instances = []
    prefix = service_template + '@'

    for service in __salt__['service.get_running']():
        if len(service) > len(prefix) and service.startswith(prefix):
            instances.append(service[len(prefix):])

    return instances
