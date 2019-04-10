package com.example.ease_life;

import android.app.Application;

import com.facebook.stetho.Stetho;

import io.flutter.app.FlutterApplication;

public class App extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        Stetho.initializeWithDefaults(this);
    }
}
