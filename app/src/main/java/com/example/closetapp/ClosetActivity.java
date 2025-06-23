package com.example.closetapp;

import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;

import java.util.List;
import java.util.Locale;

public class ClosetActivity extends AppCompatActivity {
    private TextToSpeech tts;
    private ViewPager2 viewPager;
    private TextView tvCount;
    private Button btnSpeakAll, btnDelete;

    private ClothesRepository repository;
    private List<ClothesItem> clothesList;
    private ClosetPagerAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_closet);

        repository = new ClothesRepository(this);

        // 1) 뷰 바인딩
        tvCount      = findViewById(R.id.tvCount);
        viewPager    = findViewById(R.id.viewPager);
        btnSpeakAll  = findViewById(R.id.btnSpeakAll);
        btnDelete    = findViewById(R.id.btnDelete);

        // 2) TTS 세팅
        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
                tts.speak(
                        "나의 옷장 조회/삭제 기능에 들어왔습니다. " +
                                "화면 상단을 누르면 등록된 모든 옷을 들려드리고, " +
                                "화면 중단을 좌우로 넘겨 옷을 선택할 수 있으며, " +
                                "화면 하단을 누르면 해당 옷을 삭제합니다.",
                        TextToSpeech.QUEUE_FLUSH, null, "CLOSET_PROMPT"
                );
            }
        });

        // 3) 어댑터 생성 & 연결 (초기엔 빈 리스트여도 OK)
        clothesList = repository.getAllClothes();
        adapter      = new ClosetPagerAdapter(clothesList);
        viewPager.setAdapter(adapter);

        // 4) 버튼/뷰페이저 콜백
        btnSpeakAll.setOnClickListener(v -> {
            for (ClothesItem item : clothesList) {
                tts.speak(item.getDescription(),
                        TextToSpeech.QUEUE_ADD,
                        null, null);
            }
        });

        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                String desc = clothesList.get(position).getDescription();
                tts.speak(desc, TextToSpeech.QUEUE_FLUSH, null, null);
            }
        });

        btnDelete.setOnClickListener(v -> {
            int pos = viewPager.getCurrentItem();
            ClothesItem toRemove = clothesList.get(pos);
            repository.deleteClothes(toRemove.getId());

            clothesList.remove(pos);
            adapter.notifyItemRemoved(pos);
            tvCount.setText("나의 옷 개수 : " + clothesList.size());
            tts.speak("해당 옷이 삭제되었습니다.",
                    TextToSpeech.QUEUE_FLUSH, null, null);
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        // 화면에 돌아올 때마다(새 옷 등록 후 돌아왔을 때 포함) DB 전체 조회해서 갱신
        List<ClothesItem> fresh = repository.getAllClothes();
        clothesList.clear();
        clothesList.addAll(fresh);
        adapter.notifyDataSetChanged();
        tvCount.setText("나의 옷 개수 : " + clothesList.size());
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
