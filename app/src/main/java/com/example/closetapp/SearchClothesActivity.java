package com.example.closetapp;

import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognizerIntent;
import android.speech.tts.TextToSpeech;
import android.widget.Button;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import java.util.ArrayList;
import java.util.Locale;

public class SearchClothesActivity extends AppCompatActivity{
    private static final int REQ_CODE_SPEECH = 200;
    private TextToSpeech tts;
    private Button btnMic;
    private ClothesRepository repository;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_clothes);

        repository = new ClothesRepository(this);

        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
                tts.speak(
                        "나의 옷 검색 기능입니다. 하단을 터치하여 질문해 주세요.",
                        TextToSpeech.QUEUE_FLUSH,
                        null,
                        "SEARCH_PROMPT"
                );
            }
        });

        btnMic = findViewById(R.id.btnMic);
        btnMic.setOnClickListener(v -> startSpeechRecognition());
    }

    private void startSpeechRecognition() {
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        intent.putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
        );
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.KOREAN);
        startActivityForResult(intent, REQ_CODE_SPEECH);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQ_CODE_SPEECH && resultCode == RESULT_OK && data != null) {
            ArrayList<String> results =
                    data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
            if (results != null && !results.isEmpty()) {
                String query = results.get(0);
                boolean exists = repository.isClothesRegistered(query);
                String response = exists
                        ? "현재 " + query + "은 회원님 옷장에 있습니다."
                        : query + "은 옷장에 없습니다.";
                tts.speak(response, TextToSpeech.QUEUE_FLUSH, null, "SEARCH_RESULT");
            }
        }
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
