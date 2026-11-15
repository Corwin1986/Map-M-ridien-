package fr.alexisuguz.meridien.discovery;
import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
public class DiscoveryLinkActivity extends Activity {
 @Override public void onCreate(Bundle b){super.onCreate(b);
  String id=getIntent().getStringExtra("discovery_id");
  if(id!=null&&id.matches("d[0-9]{2,4}"))getSharedPreferences(DiscoveryNotifications.PREF,MODE_PRIVATE).edit().putString("pending_link",id).commit();
  Intent launch=getPackageManager().getLaunchIntentForPackage(getPackageName());
  if(launch!=null){launch.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);startActivity(launch);}finish();
 }
}
