import '../../index.dart';

class UpdateDialog extends StatefulWidget {
  final key;
  final UpgradeInfo info;
  final Function onClickWhenDownload;
  final Function onClickWhenNotDownload;

  UpdateDialog({
    this.key,
    this.info,
    this.onClickWhenDownload,
    this.onClickWhenNotDownload,
  });

  @override
  State<StatefulWidget> createState() => UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  var _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    var _textStyle = TextStyle(color: Theme.of(context).textTheme.body1.color);

    return AlertDialog(
      title: Text(
        _downloadProgress == 0.0 ? "有新的更新" : "下载中",
        style: _textStyle,
      ),
      content: _downloadProgress == 0.0
          ? Text(
              "版本${widget.info.versionName}\r\n${widget.info.newFeature}",
              style: _textStyle,
            )
          : LinearProgressIndicator(
              value: _downloadProgress,
            ),
      actions: <Widget>[

        widget.info.updateType == 2
            ? Container()
            : FlatButton(
                child: Text(
                  '取消',
                  style: _textStyle,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
        FlatButton(
          child: Text(
            '更新',
          ),
          onPressed: () {
            if (_downloadProgress != 0.0) {
              widget.onClickWhenDownload("正在更新中");
              return;
            }
            widget.onClickWhenNotDownload();
//            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  set progress(_progress) {
    setState(() {
      _downloadProgress = _progress;
      if (_downloadProgress == 1) {
        Navigator.of(context).pop();
        _downloadProgress = 0.0;
      }
    });
  }
}
