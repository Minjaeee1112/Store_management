package com.example.closetapp;

import android.content.Intent;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import java.util.Locale;

public class HomeActivity extends AppCompatActivity {
    private TextToSpeech tts;
    private View topArea, bottomArea;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
                tts.speak(
                        "홈 화면에 들어왔습니다. 상단을 한 번 터치하면 카메라 인식, 하단을 한 번 터치하면 나의 옷장으로 이동합니다.",
                        TextToSpeech.QUEUE_FLUSH,
                        null,
                        "HOME_PROMPT"
                );
            }
        });

        topArea = findViewById(R.id.home_top);
        bottomArea = findViewById(R.id.home_bottom);

        topArea.setOnClickListener(v ->
                startActivity(new Intent(HomeActivity.this, CameraRecognitionActivity.class))
        );

        bottomArea.setOnClickListener(v ->
                startActivity(new Intent(HomeActivity.this, ClosetManageActivity.class))
        );
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
