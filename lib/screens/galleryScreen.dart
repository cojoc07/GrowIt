import 'dart:convert';
import 'package:drag_down_to_pop/drag_down_to_pop.dart';
import 'package:grow_it/model/post.dart';
import 'package:grow_it/screens/detailScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> _lista;
  List<Post> convertedList;
  bool _isLoading = true;
  List<Post> posts;
  Future<dynamic> fetchData() async {
    var url = env['URL'];

    final response = await http.get('$url');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(
        () {
          _lista = data;

          final List t = json.decode(response.body);
          posts = t.map((item) => Post.fromJson(item)).toList();

          print(posts);
          _isLoading = false;
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /* _openDetail(context, index) {
    final route = ImageViewerPageRoute(builder: (context) => DetailPage(posts: posts, index: index));
    Navigator.push(context, route);
  } */

  _openDetail(context, index) {
    final route = ImageViewerPageRoute(
        builder: (context) => DetailScreen(posts: posts, index: index));
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('random dynamic tile sizes'),
      ),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          setState(() {
            List<dynamic> test = [
              {
                "id": "42",
                "createdAt": "2021-02-26T09:22:48.418Z",
                "title": "transition",
                "url":
                    "https://cdn.pixabay.com/photo/2016/04/04/15/30/girl-1307429_960_720.jpg",
                "description": "China"
              }
            ];
            _lista.addAll(test);
          });
        },
      ),
      body: !_isLoading
          ? StaggeredGridView.countBuilder(
              itemCount: _lista.length,
              primary: false,
              crossAxisCount: width > 1000
                  ? 4
                  : width > 800
                      ? 3
                      : 2,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              itemBuilder: (context, index) => new Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26.0),
                  child: Container(
                    color: Colors.grey[850],
                    child: new Column(
                      children: <Widget>[
                        GestureDetector(
                          child: Hero(
                            tag: posts[index].url,
                            child: Center(
                              child: new FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: _lista[index]["url"],
                              ),
                            ),
                          ),
                          onTap: () => _openDetail(context, index),
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: new Column(
                            children: <Widget>[
                              new Text(
                                'Image number $index',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              new Text(
                                'Width: ',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              new Text(
                                'Height: ',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              staggeredTileBuilder: (index) => new StaggeredTile.fit(1),
            )
          : null,
    );
  }
}

class ImageViewerPageRoute extends MaterialPageRoute {
  ImageViewerPageRoute({@required WidgetBuilder builder})
      : super(builder: builder, maintainState: false);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return const DragDownToPopPageTransitionsBuilder()
        .buildTransitions(this, context, animation, secondaryAnimation, child);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return false;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return false;
  }
}
