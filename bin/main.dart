import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:http/http.dart' as http;

ArgResults argResults;

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('username',
        abbr: 'u', help: 'Provided Google DNS username', valueHelp: 'username')
    ..addOption('password',
        abbr: 'p', help: 'Provided Google DNS password', valueHelp: 'password')
    ..addOption('hostname',
        abbr: 'n',
        help: 'Google DNS hostname',
        valueHelp: 'subdomain.domain.ttl')
    ..addFlag('help', abbr: 'h', help: 'This usage manual', negatable: false);

  try {
    argResults = parser.parse(arguments);
    if (argResults['help'] as bool) {
      print('Usage:\n');
      print(parser.usage + '\n');
      exit(0);
    }
  } catch (e) {
    print(e);
    print('\nUsage:\n');
    print(parser.usage + '\n');
  }

  http.Response response = await http.get('https://api.ipify.org?format=json');
  Map<String, dynamic> publicIp;
  File lastIpFile = File('lastIP.txt');
  String lastIp;

  if (response.statusCode == 200) {
    publicIp = json.decode(response.body);
    if (lastIpFile.existsSync()) {
      lastIp = lastIpFile.readAsStringSync();
    }
    lastIpFile.writeAsStringSync(publicIp['ip']);
    if (lastIp == publicIp['ip']) {
      print('IP haven\'t changed');
    } else {
      try {
        http.Response googleDns = await http.get('https://' +
            argResults['username'] +
            ':' +
            argResults['password'] +
            '@domains.google.com/nic/update?hostname=' +
            argResults['hostname'] +
            '&myip=' +
            publicIp['ip']);
        if (googleDns.statusCode == 200) {
          print('Google says: ' + googleDns.body);
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
