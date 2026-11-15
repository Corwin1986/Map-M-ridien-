package fr.alexisuguz.meridien.discovery;
import org.junit.*;
import org.junit.runner.RunWith;
import org.robolectric.*;
import org.robolectric.annotation.Config;
import org.robolectric.shadows.*;
import android.app.*;
import android.content.*;
import android.Manifest;
import org.json.*;
import java.util.*;
import static org.junit.Assert.*;
@RunWith(RobolectricTestRunner.class) @Config(sdk={33,35},manifest=Config.NONE)
public class NotificationsTest {
 Activity a;String catalog;
 @Before public void setup()throws Exception{
  a=Robolectric.buildActivity(Activity.class).setup().get();a.getSharedPreferences(DiscoveryNotifications.PREF,0).edit().clear().commit();
  JSONArray rows=new JSONArray();Calendar day=Calendar.getInstance(TimeZone.getTimeZone("UTC"));day.clear();day.set(2024,0,1);for(int i=0;i<366;i++){String key=String.format(Locale.ROOT,"%02d-%02d",day.get(Calendar.MONTH)+1,day.get(Calendar.DAY_OF_MONTH));rows.put(new JSONObject().put("id","h"+key).put("date",key).put("title","Sujet concret "+key));day.add(Calendar.DAY_OF_MONTH,1);}catalog=rows.toString();
  Shadows.shadowOf((NotificationManager)a.getSystemService(Context.NOTIFICATION_SERVICE)).setNotificationsEnabled(true);
 }
 @Test public void defaultOff(){DiscoveryNotifications.refresh(a);assertEquals("Désactivées",DiscoveryNotifications.status(a));assertEquals(0,a.getSharedPreferences(DiscoveryNotifications.PREF,0).getLong("scheduled",0));}
 @Test public void deniedPermission(){Shadows.shadowOf((Application)a.getApplicationContext()).denyPermissions(Manifest.permission.POST_NOTIFICATIONS);assertTrue(DiscoveryNotifications.configure(a,"daily",18,0,catalog));assertFalse(DiscoveryNotifications.allowed(a));assertEquals(0,a.getSharedPreferences(DiscoveryNotifications.PREF,0).getLong("scheduled",0));}
 @Test public void allowedScheduledAndDisabled(){Shadows.shadowOf((Application)a.getApplicationContext()).grantPermissions(Manifest.permission.POST_NOTIFICATIONS);assertTrue(DiscoveryNotifications.configure(a,"daily",18,0,catalog));assertTrue(a.getSharedPreferences(DiscoveryNotifications.PREF,0).getLong("scheduled",0)>System.currentTimeMillis());DiscoveryNotifications.configure(a,"none",18,0,catalog);assertEquals(0,a.getSharedPreferences(DiscoveryNotifications.PREF,0).getLong("scheduled",0));}
 @Test public void weeklyFutureAndTimezones(){TimeZone z=TimeZone.getTimeZone("Europe/Paris");Calendar c=Calendar.getInstance(z);c.set(2026,Calendar.NOVEMBER,16,19,0,0);long next=DiscoveryNotifications.nextTime(c.getTimeInMillis(),"weekly",18,0,z);c.setTimeInMillis(next);assertEquals(Calendar.MONDAY,c.get(Calendar.DAY_OF_WEEK));assertEquals(23,c.get(Calendar.DAY_OF_MONTH));assertEquals(18,c.get(Calendar.HOUR_OF_DAY));}
 @Test public void exactHistoricalDayAndLeapDay()throws Exception{
  TimeZone z=TimeZone.getTimeZone("Europe/Paris");Calendar c=Calendar.getInstance(z);c.clear();c.set(2028,1,29,12,0);
  assertEquals("h02-29",DiscoveryNotifications.eventFor(catalog,c.getTimeInMillis(),z).getString("id"));
  c.set(2030,6,14,12,0);assertEquals("h07-14",DiscoveryNotifications.eventFor(catalog,c.getTimeInMillis(),z).getString("id"));
  assertNull(DiscoveryNotifications.eventFor("[]",c.getTimeInMillis(),z));
 }
 @Test public void catalogUpgradePreservesOptInAndNoPrompt()throws Exception{
  Shadows.shadowOf((Application)a.getApplicationContext()).grantPermissions(Manifest.permission.POST_NOTIFICATIONS);
  SharedPreferences p=a.getSharedPreferences(DiscoveryNotifications.PREF,0);p.edit().putString("frequency","weekly").putInt("hour",9).putString("catalog","[]").commit();
  DiscoveryNotifications.updateCatalog(a,catalog);assertEquals("weekly",p.getString("frequency",""));assertEquals(9,p.getInt("hour",0));assertTrue(p.getLong("scheduled",0)>System.currentTimeMillis());
  assertEquals(1,Shadows.shadowOf((AlarmManager)a.getSystemService(Context.ALARM_SERVICE)).getScheduledAlarms().size());
 }
 @Test public void notificationConcreteDeepLinkAndNoDuplicates()throws Exception{
  Shadows.shadowOf((Application)a.getApplicationContext()).grantPermissions(Manifest.permission.POST_NOTIFICATIONS);DiscoveryNotifications.configure(a,"daily",18,0,catalog);
  SharedPreferences p=a.getSharedPreferences(DiscoveryNotifications.PREF,0);long now=System.currentTimeMillis();p.edit().putLong("scheduled",now-1000).commit();
  DiscoveryNotifications receiver=new DiscoveryNotifications();receiver.onReceive(a,new Intent(DiscoveryNotifications.ACTION));
  ShadowNotificationManager n=Shadows.shadowOf((NotificationManager)a.getSystemService(Context.NOTIFICATION_SERVICE));Notification first=n.getNotification(DiscoveryNotifications.NOTICE_ID);assertNotNull(first);assertTrue(first.extras.getString(Notification.EXTRA_TEXT).startsWith("Sujet concret"));assertNotNull(first.contentIntent);
  long delivered=p.getLong("last_day",0);receiver.onReceive(a,new Intent(DiscoveryNotifications.ACTION));assertEquals(delivered,p.getLong("last_day",0));assertEquals(1,n.size());
 }
 @Test public void missedRemindersNeverBurst(){
  Shadows.shadowOf((Application)a.getApplicationContext()).grantPermissions(Manifest.permission.POST_NOTIFICATIONS);DiscoveryNotifications.configure(a,"weekly",18,0,catalog);
  SharedPreferences p=a.getSharedPreferences(DiscoveryNotifications.PREF,0);p.edit().putLong("scheduled",System.currentTimeMillis()-86400000L*120).commit();
  new DiscoveryNotifications().onReceive(a,new Intent(DiscoveryNotifications.ACTION));assertEquals(0,Shadows.shadowOf((NotificationManager)a.getSystemService(Context.NOTIFICATION_SERVICE)).size());assertTrue(p.getLong("scheduled",0)>System.currentTimeMillis());
 }
 @Test public void deepLinkConsumedOnce(){a.getSharedPreferences(DiscoveryNotifications.PREF,0).edit().putString("pending_link","d12").commit();assertEquals("d12",DiscoveryNotifications.consumeLink(a));assertEquals("",DiscoveryNotifications.consumeLink(a));}

 @Test public void preferenceChangeReplacesAlarm(){
  Shadows.shadowOf((Application)a.getApplicationContext()).grantPermissions(Manifest.permission.POST_NOTIFICATIONS);
  DiscoveryNotifications.configure(a,"daily",8,0,catalog);DiscoveryNotifications.configure(a,"weekly",20,30,catalog);
  assertEquals(1,Shadows.shadowOf((AlarmManager)a.getSystemService(Context.ALARM_SERVICE)).getScheduledAlarms().size());
  DiscoveryNotifications.configure(a,"none",20,30,catalog);assertEquals(0,Shadows.shadowOf((AlarmManager)a.getSystemService(Context.ALARM_SERVICE)).getScheduledAlarms().size());
 }
 @Test public void channelBlockedAndBootRescheduled(){
  Shadows.shadowOf((Application)a.getApplicationContext()).grantPermissions(Manifest.permission.POST_NOTIFICATIONS);DiscoveryNotifications.configure(a,"daily",18,0,catalog);
  new DiscoveryNotifications().onReceive(a,new Intent(Intent.ACTION_BOOT_COMPLETED));
  assertTrue(a.getSharedPreferences(DiscoveryNotifications.PREF,0).getLong("scheduled",0)>System.currentTimeMillis());
  Shadows.shadowOf((NotificationManager)a.getSystemService(Context.NOTIFICATION_SERVICE)).setNotificationsEnabled(false);DiscoveryNotifications.refresh(a);
  assertEquals(0,a.getSharedPreferences(DiscoveryNotifications.PREF,0).getLong("scheduled",0));
 }
 @Test public void notificationActivityRetainsTarget(){
  Intent intent=new Intent(a,DiscoveryLinkActivity.class).putExtra("discovery_id","d12");
  DiscoveryLinkActivity link=Robolectric.buildActivity(DiscoveryLinkActivity.class,intent).create().get();
  assertEquals("d12",DiscoveryNotifications.consumeLink(link));assertTrue(link.isFinishing());
 }
}
