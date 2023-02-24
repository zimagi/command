#!/usr/bin/env python3
#-------------------------------------------------------------------------------
import click
import yaml
import zimagi
import os
#-------------------------------------------------------------------------------

# host (env - ZIMAGI_HOST)
# port (env - ZIMAGI_PORT)
# user (env - ZIMAGI_USER)
# token (env - ZIMAGI_TOKEN)
# encryption_key (env - ZIMAGI_ENCRYPTION_KEY)
# log_level (env - ZIMAGI_LOG_LEVEL)
# name
# options


class ActionError(Exception):
    pass


class Action(object):

    def __init__(self, host, port, user, token, encryption_key, log_level):
        self.host = host
        self.port = port
        self.user = user
        self.token = token
        self.encryption_key = encryption_key
        self.log_level = log_level


    @property
    def client(self):
        if not getattr(self, '_client', None):
            zimagi.settings.LOG_LEVEL = self.log_level

            if self.log_level.upper() == 'DEBUG':
                print('')
                print('Environment variables')
                print('==========================================')
                for name, value in os.environ.items():
                    print("{:40s} : {}".format(name, value))
                print('')

            self._client = zimagi.CommandClient(
                user = self.user,
                token = self.token,
                encryption_key = self.encryption_key,
                host = self.host,
                port = self.port,
                message_callback = self.message_callback
            )
        return self._client

    def message_callback(self, message):
        message.display()


    def exec(self, name, options):
        response = self.client.execute(name, **options)
        if response.error:
            exit(1)


@click.command()
@click.argument('command_path', type = str, required = True)
@click.argument('command_options_yaml', type = str, default = '{}')
@click.option('-u', '--user', type = str, default = os.environ.get('ZIMAGI_USER', 'admin'))
@click.option('-t', '--token', type = str, default = os.environ.get('ZIMAGI_TOKEN', ''))
@click.option('-k', '--encryption-key', type = str, default = os.environ.get('ZIMAGI_ENCRYPTION_KEY', ''))
@click.option('-h', '--host', type = str, default = os.environ.get('ZIMAGI_HOST', 'localhost'))
@click.option('-p', '--port', type = int, default = int(os.environ.get('ZIMAGI_PORT', 5123)))
@click.option('-l', '--log-level', type = str, default = os.environ.get('ZIMAGI_LOG_LEVEL', 'WARNING'))
def main(
    command_path,
    command_options_yaml,
    user,
    token,
    encryption_key,
    host,
    port,
    log_level
):
    if not token:
        raise ActionError("To execute Zimagi commands either --token argument or ZIMAGI_TOKEN environment variable must be set")

    action = Action(host, port, user, token, encryption_key, log_level)
    action.exec(
        command_path,
        yaml.safe_load(command_options_yaml)
    )


if __name__ == '__main__':
    main()
