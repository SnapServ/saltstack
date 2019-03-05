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
    jenv.globals.update({
        'opts': __opts__,
        'salt': __salt__,
        'grains': __grains__,
        'pillar': pillar,
        'minion_id': minion_id,
    })

    # Process each glob pattern in stack file
    cfg_contents = jenv.get_template(cfg_name).render(stack=stack)
    for glob_name in _parse_stack_cfg(cfg_contents):
        # Ignore empty/whitespace-only lines
        if not glob_name.strip():
            continue

        # Attempt to find glob matches
        file_paths = glob(os.path.join(base_dir, glob_name))
        if not file_paths:
            log.info(
                'Ignoring stack pattern "{:s}": Unable to find glob matches in "{:s}"'
                .format(glob_name, base_dir))
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
