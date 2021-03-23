import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  final argParser = ArgParser()
    ..addOption(
      'username',
      abbr: 'u',
      help: 'Provided Google Domains DDNS username',
      valueHelp: 'username',
    )
    ..addOption(
      'password',
      abbr: 'p',
      help: 'Provided Google Domains DDNS password',
      valueHelp: 'password',
    )
    ..addOption(
      'hostname',
      abbr: 'n',
      help: 'Google Domains DDNS hostname',
      valueHelp: 'subdomain.domain.ttl',
    )
    ..addFlag('help', abbr: 'h', help: 'This usage manual', negatable: false);

  late ArgResults argResults;

  try {
    argResults = argParser.parse(args);
    if (argResults['help'] as bool) {
      print('\nUsage:\n');
      print(argParser.usage + '\n');
      exit(0);
    }
  } catch (e) {
    print(e);
    print('\nUsage:\n');
    print(argParser.usage + '\n');
    exit(-1);
  }

  var response = await http.get(Uri.parse('https://api64.ipify.org?format=json'));
  var lastIpFile = File('lastIP.txt');
  late Map<String, dynamic> publicIp;
  late String lastIp;

  if (response.statusCode == 200) {
    publicIp = json.decode(response.body);
    if (lastIpFile.existsSync()) {
      lastIp = lastIpFile.readAsStringSync();
    } else {
      lastIp = '';
    }
    if (lastIp == publicIp['ip']) {
      print('IP haven\'t changed');
    } else {
      try {
        lastIpFile.writeAsStringSync(publicIp['ip']);
        var googleDdnsResponse = await http.get(
          Uri.parse(
            'https://${argResults['username']}:${argResults['password']}@domains.google.com/nic/update?hostname=${argResults['hostname']}&myip=${publicIp['ip']}',
          ),
        );
        if (googleDdnsResponse.statusCode == 200) {
          print('Google says: ${googleDdnsResponse.body}');
        } else {
          print(
            'Google domains HTTP error: ${googleDdnsResponse.statusCode} ${googleDdnsResponse.reasonPhrase}',
          );
        }
      } catch (e) {
        print(e);
      }
    }
  } else {
    print(
      'HTTP error when trying to get the IP Address: ${response.statusCode} ${response.reasonPhrase}',
    );
  }
}
