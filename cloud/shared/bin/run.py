#! /usr/bin/env python3

import argparse
import shlex
import os
import sys
import importlib

# Need to add current directory to PYTHONPATH if this script is run directly.
sys.path.append(os.getcwd())

from cloud.shared.bin.lib.config_loader import ConfigLoader
from cloud.shared.bin.lib.write_tfvars import TfVarWriter
from cloud.shared.bin.lib import backend_setup


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--tag', help='Civiform image tag. Required for Setup and Deploy.')
    parser.add_argument(
        '--command',
        help='Command to run. If ommited will validate config and exit.')
    parser.add_argument(
        '--config',
        default='civiform_config.sh',
        help='Path to CiviForm deployment config file.')

    args = parser.parse_args()
    if args.tag:
        os.environ['TF_VAR_image_tag'] = args.tag
    elif args.command is not None and args.command in ['setup', 'deploy']:
        exit('--tag is required')

    os.environ['TF_VAR_FILENAME'] = "setup.auto.tfvars"
    os.environ['BACKEND_VARS_FILENAME'] = 'backend_vars'
    os.environ['TERRAFORM_PLAN_OUT_FILE'] = 'terraform_plan'

    config = ConfigLoader()
    validation_errors = config.load_config(args.config)
    if validation_errors:
        new_line = '\n\t'
        exit(
            f'Found the following validation errors: {new_line}{f"{new_line}".join(validation_errors)}'
        )

    print("Writing TF Vars file")
    terraform_tfvars_path = os.path.join(
        config.get_template_dir(), config.tfvars_filename)

    # Setup backend
    backend_setup.setup_backend(config)
    # Write the passthrough vars to a temporary file
    tf_var_writter = TfVarWriter(terraform_tfvars_path)
    tf_var_writter.write_variables(config.get_terraform_variables())

    if args.command:
        cmd = shlex.split(args.command)[0]
        params = shlex.split(args.command)[1:]
        if not os.path.exists(f'cloud/shared/bin/{cmd}.py'):
            exit(f'Command {cmd} not found.')
        command_module = importlib.import_module(f'cloud.shared.bin.{cmd}')
        if not command_module:
            exit(f'Command {cmd} not found.')
        command_module.run(config, params)


if __name__ == "__main__":
    main()
