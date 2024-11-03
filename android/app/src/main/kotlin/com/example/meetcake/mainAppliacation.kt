package com.example.meetcake
import android.app.Application;

import com.yandex.mapkit.MapKitFactory;


class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("c9779f9c-08da-40fd-b236-5f3af3b435ba");
    }
}