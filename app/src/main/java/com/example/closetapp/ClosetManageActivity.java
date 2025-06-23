package com.example.closetapp;

import android.content.Intent;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import java.util.Locale;

public class ClosetManageActivity extends AppCompatActivity {
    private TextToSpeech tts;
    private View topArea, bottomArea;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_closet_manage);

        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
                tts.speak(
                        "나의 옷장 관리 기능에 들어왔습니다." +
                                "상단을 터치하시면 나의 옷장 조회 및 삭제, " +
                                "하단을 터치하시면 나의 옷 검색 기능에 들어갑니다.",
                        TextToSpeech.QUEUE_FLUSH,
                        null,
                        "MANAGE_PROMPT"
                );
            }
        });

        topArea = findViewById(R.id.closet_manage_top);
        bottomArea = findViewById(R.id.closet_manage_bottom);

        topArea.setOnClickListener(v ->
                startActivity(new Intent(ClosetManageActivity.this, ClosetActivity.class))
        );

        bottomArea.setOnClickListener(v ->
                startActivity(new Intent(ClosetManageActivity.this, SearchClothesActivity.class))
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
