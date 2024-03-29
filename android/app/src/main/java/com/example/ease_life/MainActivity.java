package com.example.ease_life;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.inputmethod.InputMethodManager;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), "anxinju.keyboard").setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        System.out.println("call = [" + call.method + "], result = [" + result + "]");
                        if (call.method.equals("showKeyboard")) {
                            InputMethodManager inputMethodManager =
                                    (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                            //inputMethodManager.toggleSoftInputFromWindow(getWindow().getDecorView().getWindowToken(),0,InputMethodManager.SHOW_FORCED);
                            if ("0".equals(call.arguments.toString()))
                                inputMethodManager.hideSoftInputFromWindow(getWindow().getDecorView().findFocus().getWindowToken(), 0);
                            else
                                inputMethodManager.showSoftInputFromInputMethod(getWindow().getDecorView().findFocus().getWindowToken(), 0);
                            result.success(0);
                        }
                    }
                }
        );
        // ATTENTION: This was auto-generated to handle app links.
        Intent appLinkIntent = getIntent();
        String appLinkAction = appLinkIntent.getAction();
        Uri appLinkData = appLinkIntent.getData();
    }
}
