import 'package:amap_base/amap_base.dart';
import 'package:ease_life/index.dart';

//import 'package:amap_base_map/amap_base_map.dart';
class MapAndLocatePage extends StatefulWidget {
  @override
  _MapAndLocatePageState createState() => _MapAndLocatePageState();
}

class _MapAndLocatePageState extends State<MapAndLocatePage> {
  AMapController aMapController;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      BlocProviders.of<ApplicationBloc>(context)
          .locationStream
          .listen((location) {
        aMapController?.setPosition(
          target: LatLng(location?.latitude, location?.longitude),
          zoom: 15,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text("地图定位"),
      ),
      body: StreamBuilder<Location>(
          stream: BlocProviders.of<ApplicationBloc>(context).locationStream,
          builder: (context, snapshot) {
            aMapController?.setPosition(
              target: LatLng(snapshot.data?.latitude, snapshot.data?.longitude),
              zoom: 17,
            );
            return Stack(
              children: <Widget>[
                AMapView(
                  onAMapViewCreated: (AMapController controller) {
                    aMapController = controller;
                  },
                  amapOptions: AMapOptions(
                      compassEnabled: false,
                      zoomControlsEnabled: true,
                      logoPosition: LOGO_POSITION_BOTTOM_CENTER,
                      camera: CameraPosition(
                        target: LatLng(snapshot.data?.latitude ?? 30,
                            snapshot.data?.longitude ?? 100),
                        zoom: 15,
                      ),
                      scaleControlsEnabled: true,
                      mapType: MAP_TYPE_SATELLITE),
                ),
                Align(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  alignment: Alignment.center,
                ),
              ],
            );
          }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(28.0),
        child: FloatingActionButton(
          onPressed: () async {
            LatLng centerLatlng = await aMapController.getCenterLatlng();
            Fluttertoast.showToast(
                msg: '当前中心:\nlatitude--${centerLatlng.latitude},\nlongitude--${centerLatlng.longitude}');
            BlocProviders.of<ApplicationBloc>(context)
                .getCurrentLocationAndNotify();
          },
          child: Icon(Icons.my_location),
        ),
      ),
    );
  }
}
