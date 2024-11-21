import 'dart:io';

Future<String> getPrivateIpAddress() async {
  try {
    // Get all network interfaces of the device
    List<NetworkInterface> interfaces = await NetworkInterface.list();

    for (var interface in interfaces) {
      // Iterate through all addresses in each interface
      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
          print('Private IPv4 Address: ${address.address}');
          return '${address.address}';
        }
      }
    }
    return "";
  } catch (e) {
    print('Failed to get IP address: $e');

    return "";
  }
}