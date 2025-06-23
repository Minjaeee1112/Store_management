package com.example.closetapp;

import android.content.Context;
import android.speech.tts.TextToSpeech;
import java.util.Locale;
public class SpeechManager {
    private final Context context;
    private TextToSpeech tts;

    public SpeechManager(Context ctx) {
        this.context = ctx;
    }

    public void init() {
        tts = new TextToSpeech(context, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
            }
        });
    }

    public void speak(String text) {
        if (tts != null) {
            tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "유니크_ID");
        }
    }

    public void shutdown() {
        if (tts != null) {
            tts.stop();
            tts.shutdown();
        }
    }
}
