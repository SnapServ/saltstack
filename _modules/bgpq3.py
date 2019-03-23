from __future__ import absolute_import, print_function, generators, unicode_literals
import subprocess
import salt.utils.path
import salt.utils.json
from salt.exceptions import CommandExecutionError

FAMILY_FLAGS = {'ipv4': ['-4'], 'ipv6': ['-6']}
FORMAT_FLAGS = {
    'json': ['-j'],
    'ios': [],
    'ios-xe': ['-X'],
    'bird': ['-b'],
    'junos': ['-J']
}


def query(objects,
          family='ipv4',
          label='prefixes',
          format='json',
          prefix_ge=None,
          prefix_le=None,
          prefix_max=None,
          sources=None):
    cmd = salt.utils.path.which('bgpq3')
    args = [cmd, '-l', label]
    if sources:
        args.extend(['-S', ','.join(sources)])
    if prefix_ge:
        args.extend(['-r', str(prefix_ge)])
    if prefix_le:
        args.extend(['-R', str(prefix_le)])
    if prefix_max:
        args.extend(['-m', str(prefix_max)])
    if not isinstance(objects, list):
        objects = [objects]

    family_flags = FAMILY_FLAGS.get(str(family), None)
    format_flags = FORMAT_FLAGS.get(str(format), None)
    if family_flags is None:
        raise CommandExecutionError(
            'Invalid address family [{!s}] given, expected one of: {:s}'.
            format(family, ','.join(FAMILY_FLAGS.keys())))
    if format_flags is None:
        raise CommandExecutionError(
            'Invalid format type [{!s}] given, expected one of: {:s}'.format(
                format, ','.join(FORMAT_FLAGS.keys())))

    args.extend(family_flags + format_flags + objects)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()

    if process.returncode != 0:
        raise CommandExecutionError('Invocation of bgpq3 failed: {!s}', stderr)

    if format == 'json':
        data = salt.utils.json.loads(stdout)
        return data.get(label, [])

    return stdout.splitlines()
