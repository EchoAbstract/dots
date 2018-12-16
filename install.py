#!/usr/bin/env python3
import logging
import json
import os
import shutil
import sys

from pathlib import Path


def clamp(val, min, max):
    """Clamp val to be between min and max."""
    if val >= max:
        return max
    elif val <= min:
        return min
    else:
        return val


def read_json(file):
    """Read in file and return a dictionary of the JSON."""
    with open(file, 'r') as f:
        return json.loads(''.join(f.readlines()))


def copy_file(fro, to):
    """Copy from fro to to"""
    shutil.copy(fro, to)

def move_file(fro, to):
    """Move (replacingly) from fro to to"""
    os.replace(fro, to)


def link_file(fro, to):
    """Link from fro to to (unless windows, then copy)"""
    if sys.platform.startswith('win32'):
        # We *could* link, but it's better to copy...
        logging.warning('On Win32 we *copy* instead of *linking*')
        copy_file(fro, to)
    os.symlink(fro, to)

class File:
    """A file that we can 'install'"""
    def __init__(self, fro, to, f):

        if 'file' in f:
            self.source = Path(fro, f['file'])
            self.target = Path(to, f['file'])
        elif 'dest' not in f or 'src' not in f:
            logging.error('Invalid file')
        else:
            self.source = Path(fro, f['src'])
            self.target = Path(to, f['dest'])

        # Default to installing on the current platform
        self.platform = sys.platform
        if 'os' in f:
            self.platform = f['os']

        self.method = 'move'
        if 'type' in f:
            self.method = f['type']


    def perform_action(self, dry_run=False):
        """Actually do the action, unless dry_run is false, then just log it"""

        if not sys.platform.startswith(self.platform):
            logging.warning("Skipping {} as we're not on {}".format(self.source, self.platform))
            return False

        if dry_run:
            logging.warning("[DRY RUN] would {}".format(str(self)))
            return True

        if self.method == 'move':
            return move_file(self.source, self.target)
        elif self.method == 'copy':
            return move_file(self.source, self.target)
        elif self.method == 'link':
            return link_file(self.source, self.target)
        else:
            logging.error('Invalid method ({}), skipping...'.format(self.method))
            return False

        return True

    def __str__(self):
        """Debugging output for a File"""
        what = 'Move'

        if self.method == 'symlink':
            what = 'Link'
        elif self.method == 'copy':
            what = 'Copy'

        return '{} {} → {} (on {})'.format(what, self.source, self.target, self.platform)

    def __repr__(self):
        """Debugging output for a File"""
        return self.__str__()


class Manifest:
    """The manifest file for our install repo"""

    def __init__(self):
        """Initialize a Manifest, try loading the default directory first."""
        home = os.getenv('HOME')
        home_dir = Path(home)
        self.manifest_file = Path(home_dir, 'dots', 'manifest.json') # Path to this repo...

        logging.info('Trying to load default file {}'.format(self.manifest_file))

        self.is_loaded = False

        self.load(self.manifest_file)

        logging.info('Default configuration file is loaded? {}'.
                     format(self.is_loaded))


    def load(self, path):
        """Load a manifest file, replacing the current manifest"""
        logging.info('Request to load {}'.format(path))
        self.manifest_file = path

        if not path.exists():
            return False

        try:
            manifest = read_json(path)

            logging.debug(manifest)

            self.root_dir = manifest['root']

            if self.root_dir == 'HOME':
                self.root_dir = os.getenv('HOME')

            to = self.root_dir
            fro = os.path.dirname(self.manifest_file)
            self.files = [File(fro, to, f) for f in manifest['files']]

            self.is_loaded = True
            return True
        except:
            logging.error("Unexpected error:", sys.exc_info()[0])
            raise

    def install(self, dry_run=False):
        """Install this manifest, but don't if this is a dry run."""
        for f in self.files:
            logging.info('Performing: {}'.format(f))
            f.perform_action(dry_run)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='Install or link files via a manifest')
    parser.add_argument('--manifest', help='Manifest file to load')
    parser.add_argument('-v', '--verbosity', action='count', default=0)

    args = parser.parse_args()

    # NOTE: Log levels in python are 0, 10, 20, ...
    default_log_level = 30
    log_level = clamp(default_log_level - 10 * args.verbosity, 0, 100)
    logging.basicConfig(level=log_level)
    logging.debug('Using log level of {}'.format(logging.getLevelName(log_level)))

    manifest = Manifest()

    if args.manifest:
        manifest.load(Path(args.manifest))


    if manifest.is_loaded:
        manifest.install(dry_run=True)
