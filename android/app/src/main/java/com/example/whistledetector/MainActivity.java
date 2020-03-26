package com.example.whistledetector;

import android.Manifest;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.Manifest.permission.CALL_PHONE;
import static android.Manifest.permission.RECORD_AUDIO;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class MainActivity extends FlutterActivity {

    MediaRecorder recorder;

    private boolean permissionToRecordAccepted = false;
    private String[] permissions = {RECORD_AUDIO};
    private static final int REQUEST_RECORD_AUDIO_PERMISSION = 200;
    String LOG_TAG = "WHISTLEDEE";


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        permissionToRecordAccepted = grantResults[0] == PackageManager.PERMISSION_GRANTED;
        if (!permissionToRecordAccepted) {
            Log.i(LOG_TAG, "PERMISSION DENIED !!!!!!");
//            finish();
        }

        Log.i(LOG_TAG, "PERMISSION RESULT !!!!!!!!!");

    }

    private void requestPermission() {
        ActivityCompat.requestPermissions(MainActivity.this, new
                String[]{WRITE_EXTERNAL_STORAGE, RECORD_AUDIO,CALL_PHONE}, 1);
        Log.i(LOG_TAG, "REQUESTED !!!!!!!");
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        Log.i(LOG_TAG, "STARTED !!!!!!!");
        GeneratedPluginRegistrant.registerWith(flutterEngine);


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "wd/aud")
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("start")) {
                                try {
                                    if (ContextCompat.checkSelfPermission(this,
                                            RECORD_AUDIO)
                                            != PackageManager.PERMISSION_GRANTED) {
                                        requestPermission();
                                    }
                                    recorder = new MediaRecorder();
                                    recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
                                    recorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
                                    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss z");
                                    String currentDateandTime = sdf.format(new Date());
                                    recorder.setOutputFile("/sdcard/" + currentDateandTime + ".3gp");
                                    recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
                                    recorder.prepare();
                                    result.success(true);
                                } catch (IOException e) {
                                    Log.i(LOG_TAG, "Prepare failed !!!!!");
                                    e.printStackTrace();
                                    result.success(false);
                                }
                                recorder.start();
                            } else if (call.method.equals("perm")) {
                                requestPermission();
                                result.success(true);
                            } else if (call.method.equals("maxAmp")) {
                                result.success(getMaxAmp());
                            } else if (call.method.equals("stop")) {
                                if (recorder != null)
                                    recorder.stop();
                                result.success(true);
                            } else result.notImplemented();
                        }
                );
    }

    private int getMaxAmp() {
        return recorder.getMaxAmplitude();
    }
}
