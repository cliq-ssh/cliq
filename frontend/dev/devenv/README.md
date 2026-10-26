# dev Environment

This environment is used for development and testing purposes.
This provides a simple OpenSSH server, defined in `compose.yaml`, that can be used to test the application.

| Name                                        | Value     |
|---------------------------------------------|-----------|
| Config Password (`cliq-export-cliq123.txt`) | `cliq123` |
| Username                                    | `cliq`    |
| Password                                    | `cliq123` |
| Key Password                                | `cliq123` |

## Customization

You can customize environment variables by creating a `.env.local` file. The file is automatically excluded from version control.

You can customize the Docker configuration by creating a `compose.override.yaml` file. The file is automatically excluded from version control.
