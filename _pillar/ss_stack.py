# pylint: disable=missing-docstring,undefined-variable
from __future__ import absolute_import, print_function, generators, unicode_literals
import logging
import os
import os.path
import posixpath
import salt.utils.jinja
import salt.utils.yaml
from glob import glob
from jinja2 import FileSystemLoader, Environment
from salt.utils.decorators.jinja import JinjaFilter, JinjaTest, JinjaGlobal

log = logging.getLogger(__name__)


def ext_pillar(minion_id, pillar, *stack_cfgs):
    stack = {'__stack_files__': []}
    for stack_cfg in stack_cfgs:
        log.debug('Processing stack config "{:s}"'.format(stack_cfg))
        stack = _process_stack_cfg(stack_cfg, stack, minion_id, pillar)

    return stack


def _process_stack_cfg(cfg_path, stack, minion_id, pillar):
    # Initialize jinja environment
    base_dir, cfg_name = os.path.split(cfg_path)
    jenv = Environment(
        loader=FileSystemLoader(base_dir),
        extensions=['jinja2.ext.do', salt.utils.jinja.SerializerExtension])
    jenv.tests.update(JinjaTest.salt_jinja_tests)
    jenv.filters.update(JinjaFilter.salt_jinja_filters)
    jenv.globals.update(JinjaGlobal.salt_jinja_globals)
    jenv.globals.update({
        'opts': __opts__,
        'salt': __salt__,
        'grains': __grains__,
        'pillar': pillar,
        'minion_id': minion_id,
    })

    # Define global utility macros
    jenv.globals['ss_embed_file'] = jenv.from_string(''.join([
        '{%- macro ss_embed_file(path) -%}',
        '{%- import_text path as __data__ -%}',
        '{{- __data__|yaml_dquote -}}',
        '{%- endmacro -%}',
    ])).module.ss_embed_file

    # Render and parse stack configuration, removing empty entries
    cfg_contents = jenv.get_template(cfg_name).render(stack=stack)
    glob_patterns = _parse_stack_cfg(cfg_contents)
    glob_patterns = filter(None, map(lambda x: x.strip(), glob_patterns))

    # Process each glob pattern in stack configuration
    for glob_pattern in glob_patterns:
        # Attempt to find glob matches
        file_paths = glob(os.path.join(base_dir, glob_pattern))
        if not file_paths:
            log.info(
                'Ignoring stack pattern "{:s}": Unable to find glob matches in "{:s}"'
                .format(glob_pattern, base_dir))
            continue

        file_paths = sorted(file_paths)
        stack['__stack_files__'] += file_paths

        # Process each matched file
        for file_path in sorted(file_paths):
            log.debug('Processing stack file "{:s}"'.format(file_path))
            file_tpl = _to_posix_path(os.path.relpath(file_path, base_dir))
            file_contents = jenv.get_template(file_tpl).render(stack=stack)

            obj = salt.utils.yaml.safe_load(file_contents)
            if not isinstance(obj, dict):
                log.warn(
                    'Ignoring stack file "{:s}": Unable to parse as YAML dictionary'
                    .format(file_path))
                continue

            stack = __salt__['ss.merge_recursive'](stack, obj)

    return stack


def _parse_stack_cfg(contents):
    try:
        obj = salt.utils.yaml.safe_load(contents)
        if isinstance(obj, list):
            return obj
    except Exception:
        pass

    return contents.splitlines()


def _to_posix_path(path):
    return posixpath.join(*path.split(os.sep))
