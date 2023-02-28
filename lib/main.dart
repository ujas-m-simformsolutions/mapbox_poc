import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:sneakpeak_mapbox_poc/activity_map_helper.dart';
import 'package:sneakpeak_mapbox_poc/draw/drawing_painter.dart';
import 'package:sneakpeak_mapbox_poc/ripple_animation.dart';
import 'package:sneakpeak_mapbox_poc/static_data.dart';

import 'draw/drawing_points.dart';

/// Draw with custom painter
/// https://medium.com/flutter-community/drawing-in-flutter-using-custompainter-307a9f1c21f8
///
/// screen point to lat long
/// https://github.com/fleaflet/flutter_map/issues/607#issuecomment-628208311
///
/// Make sure to fulfill attribution requirements
/// https://docs.fleaflet.dev/tile-servers/using-mapbox#usage
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final latlng = LatLng(23.402765, 80.316010);
  final latlng2 = LatLng(23.49265, 80.316010);
  final rippleLatlng = LatLng(24.49265, 80.316010);
  final densityLoc1 = LatLng(23.412065, 80.316010);

  final densityLoc2 = LatLng(23.422265, 80.316010);
  bool isDrawing = false;

  late MapController mapController;
  final activityMapHelper = ActivityMapHelper();
  bool isLoading = false;
  bool isMapReady = false;
  final points = <LatLng>[
    LatLng(51.5, -0.09),
    LatLng(53.3498, -6.2603),
    LatLng(48.8566, 2.3522),
  ];
  List<DrawingPoints?> drawingPoints = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadActivityData();
  }

  Future<void> loadActivityData() async {
    isLoading = true;
    setState(() {});
    await activityMapHelper.loadJson();
    await activityMapHelper.decode();
    isLoading = false;

    setState(() {});
  }

  final handDrawing = <LatLng>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        isDrawing = !isDrawing;
       // mapController.move(rippleLatlng, 8);
        setState(() {});
      }),
      body: isLoading
          ? const CircularProgressIndicator()
          : LayoutBuilder(
              builder: (context, constrains) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    if (isDrawing) {
                      setState(() {
                        RenderBox? renderBox =
                            context.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          drawingPoints.add(DrawingPoints(
                              points: renderBox
                                  .globalToLocal(details.globalPosition),
                              paint: Paint()
                                ..strokeCap = StrokeCap.round
                                ..isAntiAlias = true
                                ..color = Colors.red
                                ..strokeWidth = 3));
                        }
                      });
                    }
                  },
                  onPanStart: (details) {
                    if (isDrawing) {
                      setState(() {
                        details.globalPosition;
                        RenderBox? renderBox =
                            context.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          drawingPoints.add(DrawingPoints(
                              points: renderBox
                                  .globalToLocal(details.globalPosition),
                              paint: Paint()
                                ..strokeCap = StrokeCap.round
                                ..isAntiAlias = true
                                ..color = Colors.red
                                ..strokeWidth = 3));
                        }
                      });
                    }
                  },
                  onPanEnd: (details) {
                    if (isDrawing) {
                      setState(() {
                        drawingPoints.add(null);
                        for (var i = 0; i < drawingPoints.length; i++) {
                          if (drawingPoints[i] != null) {
                            final drawnLatLng = _offsetToCrs(
                              // don't know what it is. It was in the github answer.
                              // Link at the top.
                              const Epsg3857(),
                              drawingPoints[i]!.points,
                              constrains,
                            );
                            if (drawnLatLng != null) {
                              handDrawing.add(drawnLatLng);
                            }
                          }
                        }
                        drawingPoints.clear();
                        mapController
                            .fitBounds(_boundsFromLatLngList(handDrawing));
                        isDrawing = false;
                      });
                    }
                  },
                  // This is required to use when using multiple touchables.
                  behavior: HitTestBehavior.opaque,
                  child: CustomPaint(
                    foregroundPainter: DrawingPainter(
                      pointsList: drawingPoints,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: IgnorePointer(
                        ignoring: isDrawing,
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            onMapEvent: (event) {
                              // Use this if you don't want to listen to stream.
                            },
                            interactiveFlags: InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag,
                            onMapReady: () {
                              setState(() {
                                isMapReady = true;
                              });
                            },
                          ),
                          children: [
                            /// Observer from mobx can be used on any layer as these
                            /// are just widgets.
                            TileLayer(
                              urlTemplate:
                                  "https://api.mapbox.com/styles/v1/ujasmajithiya/clee5y7pe001401mpg5mhdh2r/tiles/256/{z}/{x}/{y}@2x?access_token={access_token}",
                              additionalOptions: const {
                                "access_token": token,
                              },
                            ),

                            /// Free hand drawing
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: handDrawing,
                                  isFilled: true,
                                  borderStrokeWidth: 3,
                                  borderColor: Colors.green,
                                  color: Colors.greenAccent,
                                ),
                              ],
                            ),

                            /// Draws polyline
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                    points: points,
                                    strokeWidth: 4,
                                    color: Colors.purple),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                    point: rippleLatlng,
                                    builder: (_) => RippleAnimation(
                                          child:  SvgPicture.asset(
                                            'assets/coffee.svg',
                                          ),
                                          repeat: true,
                                      color: Color(0xff6DFFC1),
                                        ))
                              ],
                            ),

                            /// Markers for density
                            MarkerLayer(
                              markers: List.generate(
                                activityMapHelper.activityMapDm!.denseActivities
                                    .denseActivity.length,
                                (index) => Marker(
                                  point: LatLng(
                                    activityMapHelper
                                        .activityMapDm!
                                        .denseActivities
                                        .denseActivity[index]
                                        .latLng
                                        .first,
                                    activityMapHelper
                                        .activityMapDm!
                                        .denseActivities
                                        .denseActivity[index]
                                        .latLng
                                        .last,
                                  ),
                                  builder: (_) => SvgPicture.asset(
                                    'assets/density.svg',
                                  ),
                                  height: 20 *
                                      activityMapHelper
                                          .activityMapDm!
                                          .denseActivities
                                          .denseActivity[index]
                                          .density
                                          .toDouble(),
                                  width: 20 *
                                      activityMapHelper
                                          .activityMapDm!
                                          .denseActivities
                                          .denseActivity[index]
                                          .density
                                          .toDouble(),
                                ),
                              ),
                            ),
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                    point: LatLng(
                                        activityMapHelper
                                            .activityMapDm!.pois.first.first,
                                        activityMapHelper
                                            .activityMapDm!.pois.first.last),
                                    radius: 100,
                                    color:
                                        const Color(0xffb45309).withOpacity(.2),
                                    borderStrokeWidth: 3)
                              ],
                            ),

                            /// normal markers
                            MarkerLayer(
                              markers: List.generate(
                                activityMapHelper.activityMapDm!.pois.length,
                                (index) => Marker(
                                  point: LatLng(
                                      activityMapHelper
                                          .activityMapDm!.pois[index].first,
                                      activityMapHelper
                                          .activityMapDm!.pois[index].last),
                                  height: 100,
                                  width: 100,
                                  builder: (_) => Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/coffee.svg',
                                      ),
                                      Text('coffee')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  ///This is how we find top left and bottom right latlng from list of latlngs.
  ///Which we can use to fit map inside it.
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    ///min lat-long will become southwest coordinates and max lat-long will
    ///become northeast coordinates as its name suggests, north should be higher
    ///and south should be lower.
    double? minLat, maxLat, minLong, maxLong;
    for (final latLng in list) {
      if (minLat == null) {
        ///Assigning value to every variable
        minLat = maxLat = latLng.latitude;
        minLong = maxLong = latLng.longitude;
      } else {
        ///Calculating maximum and minimum coordinate of given
        /// list of lat-longs
        if (latLng.latitude > maxLat!) maxLat = latLng.latitude;
        if (latLng.latitude < minLat) minLat = latLng.latitude;
        if (latLng.longitude > maxLong!) maxLong = latLng.longitude;
        if (latLng.longitude < minLong!) minLong = latLng.longitude;
      }
    }
    return LatLngBounds(
      LatLng(maxLat!, maxLong!),
      LatLng(minLat!, minLong!),
    );
  }

  LatLng? _offsetToCrs(Crs crs, Offset offset, BoxConstraints constraints,
      [LatLng? initCenter, double? initZoom]) {
    var center = isMapReady ? mapController.center : initCenter;
    var zoom = isMapReady ? mapController.zoom : initZoom;

    if (center == null || zoom == null) {
      return null;
    }

    // Get the widget's offset
    var width = constraints.maxWidth;
    var height = constraints.maxHeight;

    // convert the point to global coordinates
    var localPoint = CustomPoint(offset.dx, offset.dy);
    var localPointCenterDistance =
        CustomPoint((width / 2) - localPoint.x, (height / 2) - localPoint.y);
    var mapCenter = crs.latLngToPoint(center, zoom);
    var point = mapCenter - localPointCenterDistance;
    return crs.pointToLatLng(point, zoom);
  }
}

Widget _multiMarker() {
  return DecoratedBox(
    decoration: BoxDecoration(
        color: Colors.black26, borderRadius: BorderRadius.circular(13)),
    child: Column(
      children: [
        SvgPicture.asset(
          'assets/coffee.svg',
        ),
        const SizedBox(height: 8),
        SvgPicture.asset(
          'assets/network.svg',
        ),
        const SizedBox(height: 8),
        SvgPicture.asset(
          'assets/coffee.svg',
        ),
      ],
    ),
  );
}
