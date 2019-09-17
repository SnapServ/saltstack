from __future__ import absolute_import, print_function, unicode_literals

import json
import salt.returners
import salt.utils.http
import salt.utils.jid
import requests.exceptions
from datetime import datetime, timezone
from salt.ext import six

__virtualname__ = 'myss'


def returner(ret):
    stripped_keys = ('jid', 'id', 'fun', 'fun_args', 'success', 'return')
    extra_result = dict(
        filter(lambda kv: kv[0] not in stripped_keys, six.iteritems(ret)))
    function_args = list(map(lambda x: str(x), ret.get('fun_args', [])))
    completed_at = datetime.now(timezone.utc).isoformat()

    _api_call('/saltstack/results/',
              ret=ret,
              method='POST',
              data=json.dumps({
                  'job_id': ret['jid'],
                  'minion_id': ret['id'],
                  'function': ret['fun'],
                  'function_args': function_args,
                  'success': ret.get('success', False),
                  'result_data': ret['return'],
                  'extra_data': extra_result,
                  'completed_at': completed_at,
              }))


def prep_jid(nocache=False, passed_jid=None):
    if passed_jid is not None:
        return passed_jid

    return salt.utils.jid.gen_jid(__opts__)


def save_load(jid, load, minions=None):
    try:
        _api_call('/saltstack/jobs/',
                  method='POST',
                  data=json.dumps({
                      'id': jid,
                      'payload': load,
                  }))
    except requests.exceptions.HTTPError as exc:
        if exc.response.status_code != 400:
            raise exc


def get_load(jid):
    try:
        result = _api_call('/saltstack/jobs/{}/'.format(jid))
        return result['dict']['payload']
    except Exception:
        return {}


def _api_call(resource, *, ret=None, **kwargs):
    _options = _get_options(ret)

    request_url = '{base_url}{resource}'.format(
        base_url=_options.get('api_base_url'), resource=resource)
    request_auth = 'Token {token}'.format(token=_options.get('api_token'))

    return salt.utils.http.query(url=request_url,
                                 backend='requests',
                                 decode=True,
                                 decode_type='json',
                                 raise_error=True,
                                 header_dict={
                                     'Authorization': request_auth,
                                     'Content-Type': 'application/json',
                                 },
                                 **kwargs)


def _get_options(ret=None):
    defaults = {'api_base_url': 'http://localhost/api', 'api_token': ''}
    attrs = {'api_base_url': 'api_base_url', 'api_token': 'api_token'}
    opts = salt.returners.get_returner_options(__virtualname__,
                                               ret,
                                               attrs,
                                               __salt__=__salt__,
                                               __opts__=__opts__,
                                               defaults=defaults)

    return opts
