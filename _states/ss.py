from __future__ import absolute_import, print_function, generators, unicode_literals


def resource():
    return __states__['test.configurable_test_state'](
        changes=True, result=True, comment='Resource Declaration')
