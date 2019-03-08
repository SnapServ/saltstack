from __future__ import absolute_import, print_function, generators, unicode_literals


def resource(name):
    return __states__['test.configurable_test_state'](
        name=name, changes=True, result=True, comment='Resource Declaration')
