import 'package:ease_life/bloc/user_bloc.dart';
import 'package:flutter/material.dart';

class BlocProvider extends InheritedWidget{

  final UserBloc bloc = UserBloc();

  BlocProvider({Key key,Widget child}):super(key:key,child:child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static UserBloc of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider).bloc;
  }

}
