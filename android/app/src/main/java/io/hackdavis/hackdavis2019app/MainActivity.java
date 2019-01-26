package io.hackdavis.hackdavis2019app;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.parse.Parse;
import com.parse.ParseAnonymousUtils;
import com.parse.LogInCallback;
import com.parse.ParseUser;
import com.parse.ParseException;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "hackdavis.io/login";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Parse.initialize(new Parse.Configuration.Builder(this)
                .applicationId("hackdavis2019")
                .server("https://hackdavisapp.herokuapp.com/parse")
                .build()
        );

        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if(call.method.equals("loginAnonymous")) {
                            String teamName = call.argument("teamName");
                            ParseAnonymousUtils.logIn(new MyLoginCallback(result, teamName));

                        }
                    }
                });
    }
    private class MyLoginCallback implements LogInCallback {
        private Result result;
        private String teamName;
        MyLoginCallback(Result result, String name) {
            this.result = result;
            this.teamName = name;
        }
        @Override
        public void done(ParseUser user, ParseException e) {
            if (e == null) {
                user.put("teamName", teamName);
                user.saveInBackground();
                result.success(user.getUsername());
            } else {
                result.error(e.toString(), null, null);
            }
        }
    }
}

