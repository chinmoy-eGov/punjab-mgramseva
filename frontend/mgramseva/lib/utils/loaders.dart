import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loaders {
  static circularLoader({Color? color, double? height}) {
    return Container(
      height: height,
      color: color,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  static Future<void> showLoadingDialog(BuildContext context,
      {String? label}) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SimpleDialog(
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    children: <Widget>[
                      Center(
                        child: Column(children: [
                          // CircularLoader(
                          //   color: Theme.of(context).accentColor,
                          //   size: 30.0,
//                            controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
                          // ),
                          CircularProgressIndicator(
                            color: Theme.of(context).accentColor,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            label ?? 'Loading...',
                            style: TextStyle(
                                color: Color(0xffFFFFFF),
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          )
                        ]),
                      )
                    ]),
              ));
        });
  }

  static void showLoader(BuildContext context, {String? text}) {
    showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.2),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              // backgroundColor:CustomColors.BLACK,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15)),
              child: WillPopScope(
                onWillPop: () async {
                  return true;
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Wrap(
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: [
                        SpinKitCircle(
                          color: Colors.white,
                          size: 50.0,
                        ),
                        Text(
                          text ??
                              ' Getting image data \n  Please check the values once done. ',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )),
              ),
            ),
          );
        });
  }

}
