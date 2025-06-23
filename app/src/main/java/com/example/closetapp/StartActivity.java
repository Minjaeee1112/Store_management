package com.example.closetapp;

import android.content.Intent;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import java.util.Locale;

public class StartActivity extends AppCompatActivity{
    private TextToSpeech tts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_start);

        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
                tts.speak(
                        "어플을 시작하시려면 화면을 아무 곳이나 터치해주세요",
                        TextToSpeech.QUEUE_FLUSH,
                        null,
                        "START_PROMPT"
                );
            }
        });

        View root = findViewById(R.id.start_root);
        root.setOnClickListener(v -> {
            startActivity(new Intent(StartActivity.this, HomeActivity.class));
            finish();
        });
    }

    @Override
    protected void onDestroy() {
        if (tts != null) {
            tts.stop();
            tts.shutdown();
        }
        super.onDestroy();
    }
}
