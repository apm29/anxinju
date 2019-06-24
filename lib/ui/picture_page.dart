import 'package:ease_life/index.dart';

class PicturePage extends StatefulWidget {
  final String url;

  PicturePage(this.url);

  @override
  _PicturePageState createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: NetworkImage(widget.url),
        backgroundDecoration: BoxDecoration(
          color: Colors.transparent
        ),
        gaplessPlayback: true,
        heroTag: widget.url,
      ),
    );
  }
}
