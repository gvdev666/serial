import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blue Demo',
      home: DeviceListScreen(),
    );
  }
}

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  void _getBondedDevices() async {
    List<BluetoothDevice> devices = await _flutterBlue.connectedDevices;
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Blue Demo'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothDevice device = _devicesList[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.toString()),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceListScreen(device: device),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceListScreen extends StatelessWidget {
  final BluetoothDevice device;

  ServiceListScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: StreamBuilder<List<BluetoothService>>(
        stream: device.services,
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot<List<BluetoothService>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothService service = snapshot.data![index];
                return ListTile(
                  title: Text(service.uuid.toString()),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacteristicListScreen(service: service),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}

class CharacteristicListScreen extends StatelessWidget {
  final BluetoothService service;

  CharacteristicListScreen({required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.uuid.toString()),
      ),
      body: StreamBuilder<List<BluetoothCharacteristic>>(
        stream: Stream.fromIterable([service.characteristics]),
        initialData: [],
        builder: (BuildContext context, AsyncSnapshot<List<BluetoothCharacteristic>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothCharacteristic characteristic = snapshot.data![index];
                return ListTile(
                  title: Text(characteristic.uuid.toString()),
                  onTap: () => characteristic.read(),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
