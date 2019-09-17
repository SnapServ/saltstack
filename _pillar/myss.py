from __future__ import absolute_import, print_function, unicode_literals
import logging
import re

try:
    from salt.ext.six.moves.urllib.parse import quote as _quote
    _HAS_DEPENDENCIES = True
except ImportError:
    _HAS_DEPENDENCIES = False

log = logging.getLogger(__name__)


def __virtual__():
    return _HAS_DEPENDENCIES


def ext_pillar(
        minion_id,
        pillar,  # pylint: disable=W0613
        url,
        with_grains=False,
        options=None):
    '''
    Read pillar data from HTTP response.
    :param str url: Url to request.
    :param dict with_options: Custom options passed to salt['http.query'].
    :return: A dictionary of the pillar data to add.
    :rtype: dict
    '''

    url = url.replace('%s', _quote(minion_id))
    options = {} if options is None else options

    log.debug('Getting pillar data from myss: %s', url)
    data = __salt__['http.query'](url=url,
                                  decode=True,
                                  decode_type='json',
                                  **options)
    if 'dict' in data:
        return data['dict']

    log.error("Error on minion '%s' myss query: %s\nMore Info:\n", minion_id,
              url)
    for key in data:
        log.error('%s: %s', key, data[key])

    return {}
