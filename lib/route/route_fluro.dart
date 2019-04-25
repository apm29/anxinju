import 'package:fluro/fluro.dart';

final routes = Router();

var userHandler = Handler(
  handlerFunc: (context,params){

  }
);

void defineRoutes(Router route){
  route.define("/user/:id", handler: null);
}