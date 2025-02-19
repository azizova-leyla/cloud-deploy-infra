import sys

from cloud.aws.templates.aws_oidc.bin import resources
from cloud.aws.templates.aws_oidc.bin.aws_cli import AwsCli
from cloud.shared.bin.lib import terraform


def run(config):
    if not terraform.perform_apply(config):
        sys.stderr.write('Terraform deployment failed.')
        # TODO(#2606): write and upload logs.
        raise ValueError('Terraform deployment failed.')

    if config.is_test():
        print('Test completed')

    print()
    print('Deployment finished. You can monitor civiform tasks status here:')
    print(
        AwsCli(config).get_url_of_fargate_tasks(
            f'{config.app_prefix}-{resources.CLUSTER}',
            f'{config.app_prefix}-{resources.FARGATE_SERVICE}'))
