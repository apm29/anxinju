import 'package:ease_life/index.dart';
///
/// yjw
/// loading框,以后再确定样式 todo: dialog style
///
class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SizedBox(
          width: constraint.biggest.width,
          height: constraint.biggest.height,
          child: AbsorbPointer(
            child: Container(
              color: Color(0x33333333),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }
}