import 'package:driver_app/page/database_page.dart';
import 'package:driver_app/page/wifi_page.dart';
import 'package:flutter/material.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';

class rutePage extends StatefulWidget {
  const rutePage({Key? key}) : super(key: key);

  @override
  State<rutePage> createState() => _rutePageState();
}

class _rutePageState extends State<rutePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isOpened = false;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (isOpened) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    isOpened = !isOpened;
  }

  String display = '';
  @override
  Widget build(BuildContext context) {
    final GlobalKey<AnimatedFloatingActionButtonState> key =
        GlobalKey<AnimatedFloatingActionButtonState>();

    List<Map<String, dynamic>> dataList = [
      {"noCar": "A10", "jurusan": 'Depok - Jakarta'},
      {"noCar": "A10", "jurusan": 'Cepok - bekasi'},
      {"noCar": "A10", "jurusan": 'Cicaheum - jakarta'},
    ];

    Widget float1() {
      return Container(
        child: FloatingActionButton(
          onPressed: null,
          heroTag: "btn1",
          tooltip: 'First button',
          child: Icon(Icons.add),
        ),
      );
    }

    Widget float2() {
      return Container(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: ((context) => databasePage())));
          },
          heroTag: "btn2",
          tooltip: 'Second button',
          child: Icon(Icons.edit),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: AnimatedFloatingActionButton(
          //Fab list
          fabButtons: <Widget>[float1(), float2()],
          key: key,
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.red,
          animatedIconData: AnimatedIcons.menu_close //To principal button
          ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                  ),
                  Center(
                    child: Text(
                      display,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  final String noCar = dataList[index]['noCar'];
                  final String jurusan = dataList[index]['jurusan'];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          display = '${noCar},${jurusan}';
                          setState(() {});
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${noCar},${jurusan}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                              Align(
                                child: IconButton(onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: ((context) => wifiPage(message: '${noCar},${jurusan}'))));
                                }, icon: Icon(Icons.send)))
                            ],
                          ),
                        )),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
