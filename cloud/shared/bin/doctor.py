#! /usr/bin/env python3

from lib.check import Check
import platform
import re

detected_platform = platform.system()
is_linux = detected_platform == 'Linux'
is_mac = detected_platform == 'Darwin'

AZURE_VERSION_REGEXP = re.compile(r'^.*\s(\d+\.\d+\.\d+).*$')

if not is_linux and not is_mac:
    raise RuntimeError("Only Linux and macOS are supported.")


class DockerCheck(Check):
    remedy = "Need to install Docker CLI: https://docs.docker.com/engine/install/"

    def name(self):
        return "Docker CLI"

    def is_ok(self):
        return self._check_command_succeeds(["docker", "--version"])


class TerraformCheck(Check):
    remedy = "Need to install Terraform CLI: https://learn.hashicorp.com/tutorials/terraform/install-cli"

    def name(self):
        return "Terraform CLI"

    def is_ok(self):
        return self._check_command_succeeds(["terraform", "-version"])


class JavaCheck(Check):

    def name(self):
        return "Java JRE"

    def is_ok(self):
        return self._check_command_succeeds(["java", "-version"])

    def remedy_linux(self):
        return """
            Need to install Java JRE
            https://docs.oracle.com/javase/9/install/installation-jdk-and-jre-linux-platforms.htm#JSJIG-GUID-737A84E4-2EFF-4D38-8E60-3E29D1B884B8
        """

    def remedy_mac(self):
        return """
            Need to install Java JRE
            https://docs.oracle.com/javase/9/install/installation-jdk-and-jre-macos.htm#JSJIG-GUID-2FE451B0-9572-4E38-A1A5-568B77B146DE
        """


class KeytoolCheck(Check):

    def name(self):
        return "Java Keytool"

    def is_ok(self):
        return self._check_command_succeeds(["keytool"])

    def remedy_linux(self):
        return """
            Keytool is usually installed with Java. If this check is failing but the Java JRE check is not, you may need to try reinstalling Java with a newer version.
            https://docs.oracle.com/javase/9/install/installation-jdk-and-jre-linux-platforms.htm#JSJIG-GUID-737A84E4-2EFF-4D38-8E60-3E29D1B884B8
        """

    def remedy_mac(self):
        return """
            Keytool is usually installed with Java. If this check is failing but the Java JRE check is not, you may need to try reinstalling Java with a newer version.
            https://docs.oracle.com/javase/9/install/installation-jdk-and-jre-macos.htm#JSJIG-GUID-2FE451B0-9572-4E38-A1A5-568B77B146DE
        """


class AwsCliCheck(Check):
    remedy = """
        Need to install the AWS CLI tool.
        https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    """

    def name(self):
        return "AWS CLI"

    def should_skip(self):
        # AWS SES is used for both Azure and AWS deployments.
        return self._get_cloud_provider() not in ['aws', 'azure']

    def is_ok(self):
        return self._check_command_succeeds(["aws", "--version"])


class AzureCliCheck(Check):
    remedy = """
        Need to install the Azure CLI tool.
        https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    """

    def name(self):
        return "Azure CLI"

    def should_skip(self):
        return self._get_cloud_provider() != "azure"

    def is_ok(self):
        return self._check_command_succeeds(["az"])


class AzureCliVersionCheck(Check):
    MIN_VERSION = "2.34.1"

    remedy = f"""
        Azure CLI tool must be at version {MIN_VERSION} or above.
        https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    """

    def name(self):
        return "Azure CLI version"

    def should_skip(self):
        return self._get_cloud_provider() != "azure"

    def is_ok(self):
        azure_version_info = self._get_command_output(
            [
                "/bin/bash",
                "-c",
                "az --version 2> /dev/null",
            ])
        # Search for the azure-cli version. Sample outputs on
        # different systems:
        # azure-cli                         2.36.0
        # azure-cli                         2.34.1 *
        azure_cli_lines = [
            l for l in azure_version_info.split('\n')
            if l.startswith('azure-cli')
        ]
        if len(azure_cli_lines) != 1:
            print(
                'could not find single azure-cli entry in az --version output')
            return False

        cli_version_match = AZURE_VERSION_REGEXP.match(azure_cli_lines[0])
        if not cli_version_match:
            print(
                f'could not determine the azure_cli_version from the az --version output: got "{azure_cli_lines}"'
            )
            return False
        azure_cli_version_string = cli_version_match.groups()[0]
        return self.version_at_least(self.MIN_VERSION, azure_cli_version_string)


class AwsLoginCheck(Check):
    remedy = """
        Need to configure AWS CLI tool. Run `aws configure` and enter credentials
        or for other options visit
        https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
    """

    def name(self):
        return "AWS login"

    def should_skip(self):
        # AWS SES is used for both Azure and AWS deployments.
        return self._get_cloud_provider() not in ['aws', 'azure']

    def is_ok(self):
        output = self._get_command_output(["aws", "sts", "get-caller-identity"])

        # If AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are not set, the above
        # command will print nothing to stdout and an error message to stderr.
        # If they are set, a json object with the following keys will be
        # printed to stdout.
        return 'UserId' in output and 'Account' in output and 'Arn' in output


class AzureLoginCheck(Check):
    remedy = """
        Need to authenticate with the Azure CLI tool.
        https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli
    """

    def name(self):
        return "Azure login"

    def should_skip(self):
        return self._get_cloud_provider() != "azure"

    def is_ok(self):
        return self._check_command_succeeds(
            ["az", "ad", "signed-in-user", "show"])


checks = [
    DockerCheck(),
    TerraformCheck(),
    JavaCheck(),
    KeytoolCheck(),
    AwsCliCheck(),
    AzureCliCheck(),
    AzureCliVersionCheck(),
    AwsLoginCheck(),
    AzureLoginCheck()
]

problems = []
for check in checks:
    if check.should_skip():
        continue

    print(check.name().ljust(30, "."), end="", flush=True)

    if check.is_ok():
        print("OK")
        continue

    print("FAILED")
    problems.append(check)

if len(problems) == 0:
    print("All checks passed!")
    exit(0)

print("\nSome checks failed, please do the fix for each failure:")

for failed_check in problems:
    print(f"\n{failed_check.name()}")

    if is_linux:
        remedy = failed_check.remedy_linux()
    elif is_mac:
        remedy = failed_check.remedy_mac()
    else:
        raise RuntimeError("Only Linux and macOS are supported.")

    remedy_lines = remedy.splitlines()

    for line in remedy_lines:
        line = line.strip()

        if line == "":
            continue

        print(f"\t{line}")

exit(1)
