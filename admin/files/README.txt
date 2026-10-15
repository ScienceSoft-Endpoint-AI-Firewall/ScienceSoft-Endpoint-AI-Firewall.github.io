ScienceSoft AI Endpoint Firewall: server installer (install.sh)
================================================================

WHAT THIS IS

install.sh is the first step of installing the ScienceSoft AI Endpoint Firewall
server (the "control plane"). It prepares an empty Ubuntu server and installs one
command, aifw. You then run "sudo aifw setup", which installs and configures
everything else: the server, the admin portal, the sign-in service (Keycloak), the
database, HTTPS and monitoring.

The whole sequence:

    sudo bash install.sh
    sudo aifw setup

In this folder:

    install.sh     the installer script
    README.txt     this file
    SHA256SUMS     the checksum of install.sh, to check that the file is intact

The full guide, with every option of "aifw setup", is in the Administrator Guide of
the documentation: Install the server with aifw.


BEFORE YOU START

You need:

  * An Ubuntu server. Ubuntu 24.04 LTS is the tested system. On another system the
    script prints a note and continues. Intel/AMD (x86_64) and ARM (aarch64)
    processors are supported.
  * Administrator rights: you run the script with sudo.
  * Internet access from the server: to the Ubuntu package archive, to the software
    registry, and (for Let's Encrypt) to the certificate authority.
  * From your welcome email: the registry access name and the registry access
    token, and your license file. The software cannot be downloaded without the
    access details.
  * The server size and ports from the "Prerequisites" page of the guide.

Take a snapshot or backup of the server first. If you later have to change an
installation setting, you restore the snapshot and run setup again.


HOW TO USE IT

1. Copy install.sh to the server. If you copied it from a Windows computer, convert
   the line endings first, or it can fail without a message:

       sed -i 's/\r$//' install.sh

2. Check that the file is intact (optional, recommended). The result must be "OK":

       sha256sum -c SHA256SUMS

3. Run it as administrator:

       sudo bash install.sh

4. When asked, enter the registry access name and the access token from your
   welcome email. What you type for the token is hidden. They are checked at once.

5. Wait for it to finish. It ends with:

       Done. The aifw command is installed:
       aifw <version>

       Next step:  sudo aifw setup

6. Check the server, then set it up:

       sudo aifw preflight
       sudo aifw setup


WHAT THE SCRIPT DOES, IN ORDER

  1. Checks that you are running it as administrator.
  2. Notes the operating system. It continues on a system other than Ubuntu 24.04.
  3. Checks the processor type (x86_64 or aarch64). Any other type stops the script
     before anything is changed.
  4. Installs Docker Engine and the Docker Compose component, if they are missing.
     Docker is installed from the Ubuntu package archive.
  5. Signs in to the software registry with your access name and token, and checks
     them.
  6. Downloads the installer image for this processor type and takes the aifw
     command out of it.
  7. Puts aifw at /usr/local/bin/aifw, and prints its version.

It does not set up the server. That is "aifw setup".

The registry sign-in is stored for the administrator account (root), in Docker's
settings, so that "aifw upgrade" can download newer versions later. The access token
should be a read-only access token.


SETTINGS (ENVIRONMENT VARIABLES)

You can give the script its settings in the environment, for an unattended
installation. All are optional except the two access values, which are asked for
when they are not set.

    AIFW_REGISTRY_USER    the registry access name
    AIFW_REGISTRY_TOKEN   the registry access token
    AIFW_VERSION          the version of the installer to download. By default:
                          the version this server already runs, or "latest" on a
                          new server
    AIFW_REGISTRY         the software registry address (set by default)
    AIFW_REGISTRY_PATH    the project in the registry (set by default)

Example, with no questions asked:

    sudo AIFW_REGISTRY_USER='<name>' AIFW_REGISTRY_TOKEN='<token>' bash install.sh

Note: a command line can be seen by other users of the server for a moment, and can
stay in the shell history. Prefer the questions on the screen, unless the
installation is automated and the secret comes from a secret store.

To install a specific version:

    sudo AIFW_VERSION=<version> bash install.sh

Running the script again is safe. It repairs a damaged aifw command. On a server that
already runs AI Firewall, it keeps the version that the server runs, unless you set
AIFW_VERSION.


IF SOMETHING GOES WRONG

The script stops with a line that starts with "Problem:". Typical ones:

  * "this installer needs administrator rights"
        Run it with sudo: sudo bash install.sh
  * "AI Firewall server software is published for Intel/AMD (x86_64) and ARM
    (aarch64) servers"
        The server has another processor type. Use a supported server.
  * "another program is installing software right now"
        Often the automatic security updater, just after the server started. Wait a
        minute and run the script again.
  * "this server could not reach the Ubuntu package archive"
        Check the internet access and proxy settings of the server.
  * "both the access name and the token are needed"
        Both are in your welcome email. Ask your ScienceSoft contact if you cannot
        find them.
  * "the registry did not accept the access token"
        Check for typing mistakes. If it still fails, ask your ScienceSoft contact
        for a new token.
  * "could not download the installer image"
        Check the internet access of the server to the software registry.
  * "this version ... was not published for ... machines"
        There is no build for this processor type. Ask your ScienceSoft contact, or
        use an Intel/AMD server.
  * "could not write the aifw command"
        The disk is full or read-only. Check with: df -h /usr/local/bin

After you fix the cause, run the script again.


SECURITY NOTES

  * Read the script before you run it as administrator. It is a short, plain shell
    script.
  * Download it only from the documentation site or the welcome email, and check the
    checksum.
  * Keep the registry access token secret. Do not put it into tickets or chats.


SUPPORT

Contact your ScienceSoft representative. Send them the exact "Problem:" line that
the script printed. Do not send the token.
