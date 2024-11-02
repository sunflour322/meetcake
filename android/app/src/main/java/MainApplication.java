

import android.app.Application;

import com.yandex.mapkit.MapKitFactory;

public class MainApplication extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    MapKitFactory.setApiKey("c9779f9c-08da-40fd-b236-5f3af3b435ba");
  }
}