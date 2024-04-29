## As Google had sold their Domains business to Squarespace and they don`t support DDNS, this repo is archived as of April/2024



# Google Domains DDNS updater

Google Domains DDNS updater is a command-line application to automatic update your IP address on Google Domains DDNS service written in Dart.

To run it you need the Dart SDK to compile the code or interpret it.

### Usage

- Install the Dart SDK as stated in [dart.dev](https://dart.dev)
- Execute the program as
```Shell
dart main.dart -u USERNAME_PROVIDED_BY_GOOGLE -n PASSWORD_PROVIDED_BY_GOOGLE -n YOUR.DDNS.HOSTNAME.tld
```
- To automatically update the IP address, configure the above command as a CRON job, preferably, every 1 hour
