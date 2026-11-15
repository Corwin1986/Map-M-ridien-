package fr.alexisuguz.meridien.discovery;
import android.Manifest;
import android.app.*;
import android.content.*;
import android.content.pm.PackageManager;
import android.os.Build;
import org.json.*;
import java.util.*;

/** Device-only reminders. One inexact future alarm, no backlog, no networking. */
public class DiscoveryNotifications extends BroadcastReceiver {
 public static final String PREF="meridien_reminders_v1", CHANNEL="meridien_discovery", ACTION="fr.alexisuguz.meridien.DISCOVERY";
 public static final int ALARM_ID=1401, NOTICE_ID=1402;
 static SharedPreferences prefs(Context c){return c.getSharedPreferences(PREF,Context.MODE_PRIVATE);}
 static NotificationManager manager(Context c){return (NotificationManager)c.getSystemService(Context.NOTIFICATION_SERVICE);}
 public static boolean allowed(Context c){
  if(Build.VERSION.SDK_INT>=33 && c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)!=PackageManager.PERMISSION_GRANTED)return false;
  if(!manager(c).areNotificationsEnabled())return false;
  if(Build.VERSION.SDK_INT>=26){NotificationChannel ch=manager(c).getNotificationChannel(CHANNEL);if(ch!=null && ch.getImportance()==NotificationManager.IMPORTANCE_NONE)return false;}
  return true;
 }
 static void channel(Context c){if(Build.VERSION.SDK_INT>=26)manager(c).createNotificationChannel(new NotificationChannel(CHANNEL,"Découvertes de Méridien",NotificationManager.IMPORTANCE_DEFAULT));}
 public static String status(Activity a){
  String mode=prefs(a).getString("frequency","none");
  if(mode.equals("none"))return "Désactivées";
  if(!allowed(a))return "Non autorisées dans Android. Aucun rappel ne sera affiché.";
  return "Autorisées · "+(mode.equals("daily")?"quotidiennes":"hebdomadaires (lundi)")+" · horaire indicatif";
 }
 public static void openSettings(Activity a){
  Intent i;
  if(Build.VERSION.SDK_INT>=26)i=new Intent(android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(android.provider.Settings.EXTRA_APP_PACKAGE,a.getPackageName());
  else i=new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS,android.net.Uri.parse("package:"+a.getPackageName()));
  a.startActivity(i);
 }
 public static boolean configure(Activity a,String frequency,int hour,int minute,String catalog){
  if(!Arrays.asList("none","daily","weekly").contains(frequency)||hour<0||hour>23||minute<0||minute>59)return false;
  if(!validCatalog(catalog))return false;
  cancel(a);
  if(!prefs(a).edit().putString("frequency",frequency).putInt("hour",hour).putInt("minute",minute).putString("catalog",catalog).commit())return false;
  if(frequency.equals("none"))return true;
  channel(a);
  if(Build.VERSION.SDK_INT>=33 && a.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)!=PackageManager.PERMISSION_GRANTED){
   a.runOnUiThread(()->a.requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS},1414));
  } else refresh(a);
  return true;
 }
 static boolean validCatalog(String catalog){
  try{JSONArray rows=new JSONArray(catalog);if(rows.length()==0)return false;Set<String> dates=new HashSet<>();for(int i=0;i<rows.length();i++){JSONObject row=rows.getJSONObject(i);row.getString("id");row.getString("title");String date=row.getString("date");if(!date.matches("[0-9]{2}-[0-9]{2}")||!dates.add(date))return false;}return true;}catch(Exception e){return false;}
 }
 public static void updateCatalog(Activity a,String catalog){
  if(!validCatalog(catalog)||catalog.equals(prefs(a).getString("catalog","")))return;
  prefs(a).edit().putString("catalog",catalog).commit();cancel(a);schedule(a,true);
 }
 public static JSONObject eventFor(String catalog,long now,TimeZone tz){
  Calendar date=Calendar.getInstance(tz);date.setTimeInMillis(now);
  String key=String.format(Locale.ROOT,"%02d-%02d",date.get(Calendar.MONTH)+1,date.get(Calendar.DAY_OF_MONTH));
  try{JSONArray rows=new JSONArray(catalog);for(int i=0;i<rows.length();i++){JSONObject row=rows.getJSONObject(i);if(key.equals(row.optString("date")))return row;}}catch(Exception ignored){}
  return null;
 }
 static PendingIntent alarmIntent(Context c){return PendingIntent.getBroadcast(c,ALARM_ID,new Intent(c,DiscoveryNotifications.class).setAction(ACTION),PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);}
 public static void cancel(Context c){((AlarmManager)c.getSystemService(Context.ALARM_SERVICE)).cancel(alarmIntent(c));manager(c).cancel(NOTICE_ID);prefs(c).edit().remove("scheduled").apply();}
 public static long nextTime(long now,String frequency,int hour,int minute,TimeZone tz){
  Calendar next=Calendar.getInstance(tz);next.setTimeInMillis(now);next.set(Calendar.HOUR_OF_DAY,hour);next.set(Calendar.MINUTE,minute);next.set(Calendar.SECOND,0);next.set(Calendar.MILLISECOND,0);
  if(frequency.equals("weekly")){while(next.get(Calendar.DAY_OF_WEEK)!=Calendar.MONDAY)next.add(Calendar.DAY_OF_MONTH,1);}
  if(next.getTimeInMillis()<=now)next.add(Calendar.DAY_OF_MONTH,frequency.equals("weekly")?7:1);
  return next.getTimeInMillis();
 }
 public static long localDay(long now,TimeZone tz){Calendar c=Calendar.getInstance(tz);c.setTimeInMillis(now);Calendar u=Calendar.getInstance(TimeZone.getTimeZone("UTC"));u.clear();u.set(c.get(Calendar.YEAR),c.get(Calendar.MONTH),c.get(Calendar.DAY_OF_MONTH));return u.getTimeInMillis()/86400000L;}
 public static void refresh(Activity a){schedule(a,false);}
 static void schedule(Context c,boolean reset){
  SharedPreferences p=prefs(c);String frequency=p.getString("frequency","none");
  if(frequency.equals("none")||!allowed(c)){cancel(c);return;}
  long now=System.currentTimeMillis();long existing=p.getLong("scheduled",0);
  if(!reset && existing>now)return;
  long next=nextTime(now,frequency,p.getInt("hour",18),p.getInt("minute",0),TimeZone.getDefault());
  int tries=0;
  while(eventFor(p.getString("catalog","[]"),next,TimeZone.getDefault())==null && tries++<366){next=nextTime(next,frequency,p.getInt("hour",18),p.getInt("minute",0),TimeZone.getDefault());}
  if(tries>=366){cancel(c);return;}
  p.edit().putLong("scheduled",next).commit();
  ((AlarmManager)c.getSystemService(Context.ALARM_SERVICE)).setWindow(AlarmManager.RTC_WAKEUP,next,3600000L,alarmIntent(c));
 }
 public static String consumeLink(Activity a){String id=prefs(a).getString("pending_link","");prefs(a).edit().remove("pending_link").commit();return id;}
 @Override public void onReceive(Context c,Intent intent){
  if(!ACTION.equals(intent.getAction())){schedule(c,true);return;}
  SharedPreferences p=prefs(c);long now=System.currentTimeMillis(),due=p.getLong("scheduled",0);long day=localDay(now,TimeZone.getDefault());
  // Ignore stale deliveries (e.g. phone switched off for days), and duplicate broadcasts.
  if(!p.getString("frequency","none").equals("none")&&allowed(c)&&due>0&&now>=due&&localDay(due,TimeZone.getDefault())==day&&p.getLong("last_day",Long.MIN_VALUE)!=day){
   try{
    JSONObject d=eventFor(p.getString("catalog","[]"),now,TimeZone.getDefault());
    if(d==null)throw new IllegalStateException("No event for this date");
    channel(c);
    Intent open=new Intent(c,DiscoveryLinkActivity.class).putExtra("discovery_id",d.getString("id"));
    PendingIntent content=PendingIntent.getActivity(c,NOTICE_ID,open,PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
    Notification.Builder b=Build.VERSION.SDK_INT>=26?new Notification.Builder(c,CHANNEL):new Notification.Builder(c);
    b.setSmallIcon(android.R.drawable.ic_dialog_map).setContentTitle("Méridien · Découverte du jour").setContentText(d.getString("title")).setStyle(new Notification.BigTextStyle().bigText(d.getString("title"))).setContentIntent(content).setAutoCancel(true).setOnlyAlertOnce(true);
    manager(c).notify(NOTICE_ID,b.build());p.edit().putLong("last_day",day).commit();
   }catch(Exception ignored){/* Keep app usable; next reminder can retry. */}
  }
  p.edit().remove("scheduled").commit();schedule(c,true);
 }
}
