package com.example.fugadafronteira;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.content.pm.ActivityInfo;
public class MainActivity extends Activity {
 private WebView web;
 @Override public void onCreate(Bundle b){super.onCreate(b);setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
 getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY|View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_HIDE_NAVIGATION|View.SYSTEM_UI_FLAG_LAYOUT_STABLE|View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION|View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
 web=new WebView(this);web.setWebViewClient(new WebViewClient());WebSettings s=web.getSettings();s.setJavaScriptEnabled(true);s.setDomStorageEnabled(true);s.setSupportZoom(false);setContentView(web);web.loadUrl("file:///android_asset/index.html");}
 @Override public void onBackPressed(){super.onBackPressed();}
}