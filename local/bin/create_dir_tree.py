#!/usr/bin/env python3
import json
import argparse
import os
import subprocess
import shutil
import sys


def setup_arg_parser():
    argp = argparse.ArgumentParser()
    argp.add_argument('-r', '--root', dest='root_dir', help='The root of the directory that you '
                      'want to traverse')
    argp.add_argument('-t', '--target', dest='target_dir', help='The target directory where you '
                      'want to recreate the directory tree of root')
    argp.add_argument('-p', '--pretend', dest='pretend', help='Simulate what you would do instead '
                      'of actually doing it', action='store_true')
    argp.add_argument('-d', '--delete', dest='delete', help='Recursively delete all files in '
                      'directory before creating file structure', action='store_true')
    argp.add_argument('-P', '--pipe', dest='pipe', help='Accept piped JSON input from "tree -J" '
                      'instead of using the root parameter', action='store_true')
    return argp


def print_args(args):
    print('Arguments are:')
    for k, v in args.items():
        print('\t"{}": "{}"'.format(k, v))
    print('\n')


def get_directory_tree(root_dir):
    return subprocess.check_output(['tree', '-J', root_dir], universal_newlines=True)


def create_directory_tree(directory_tree, target_dir, pretend):
    for item in directory_tree:
        if item['type'] == 'directory':
            if pretend:
                print('Dir: {}'.format(item['name']))
            else:
                if not os.path.exists('/'.join([target_dir, item['name']])):
                    os.makedirs('/'.join([target_dir, item['name']]))
            create_directory_tree(item['contents'], '/'.join([target_dir, item['name']]), pretend)
        elif item['type'] == 'file':
            if pretend:
                print('\tFile: {}'.format(item['name']))
            else:
                open('/'.join([target_dir, item['name']]), 'a').close()

# Parse the command line arguments
cli_args = setup_arg_parser().parse_args()
root_dir = cli_args.root_dir
pretend = cli_args.pretend
target_dir = cli_args.target_dir
delete = cli_args.delete
pipe = cli_args.pipe
print_args({'root_dir': root_dir, 'pretend': pretend, 'target_dir': target_dir, 'delete': delete,
            'pipe': pipe})

if root_dir is None and pipe is False:
    print('--root/-r OR --pipe/-p arguments were left off, nothing to do here')
    exit(1)
if root_dir is not None and pipe is True:
    print('Cannot specify both root and pipe options, they are mutually exclusive')
    exit(1)
if target_dir is None:
    print('--target/-t arguments were left off, nothing to do here')
    exit(1)

if delete:
    shutil.rmtree(target_dir)
    os.mkdir(target_dir)

if root_dir is not None:
    directory_tree = json.loads(get_directory_tree(root_dir))
elif pipe:
    directory_tree = json.loads(''.join(sys.stdin.readlines()))
#print(directory_tree)

create_directory_tree(directory_tree, target_dir, pretend)
