package com.example.closetapp;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.ColorUtils;

import java.util.Locale;

public class RecognitionResultActivity extends AppCompatActivity {
    private TextToSpeech tts;
    private GestureDetector detector;
    private TextView tvResult;
    private ClothesRepository repository;
    private String imagePath, descriptionText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.recognition_result_activity);

        // --- 1) Intent에서 데이터 꺼내기 ---
        Intent intent = getIntent();
        String rawColor       = intent.getStringExtra("color");       // 예: "#677694"
        String rawType        = intent.getStringExtra("type");        // 예: "shirt" 또는 "Blue" (잘못 오면 매핑 실패할 수 있음)
        String rawPattern     = intent.getStringExtra("pattern");     // 예: "none"
        String rawDescription = intent.getStringExtra("description"); // (ChatGPT에서 넘어온 문장, 필요시 사용)
        imagePath             = intent.getStringExtra("imagePath");   // 화면에 저장할 이미지 경로(필요하다면)
        descriptionText       = rawDescription;                        // DB에 같이 저장할 설명(필요하다면)

        // 매핑 전 애플리케이션 로그에 원본 값 찍어보기(디버그용)
        Log.d("RecognitionResult", "원본(raw) → color=" + rawColor +
                ", type=" + rawType +
                ", pattern=" + rawPattern);

        // --- 2) 원본(English/hex) → 한글/기본값으로 매핑 ---
        String korColor   = mapColorToKorean(rawColor);
        String korType    = mapTypeToKorean(rawType);
        String korPattern = mapPatternToKorean(rawPattern);

        // --- 3) 화면에 뿌려주기 ---
        tvResult = findViewById(R.id.tvResult);
        String text = String.format(
                "색상 : %s\n종류 : %s\n패턴 : %s",
                korColor, korType, korPattern
        );
        tvResult.setText(text);

        // --- 4) TTS 초기화 & 프롬프트 읽기 ---
        tts = new TextToSpeech(this, status -> {
            if (status == TextToSpeech.SUCCESS) {
                tts.setLanguage(Locale.KOREAN);
                String prompt = String.format(
                        "색상은 %s, 종류는 %s, 패턴은 %s입니다. 화면 중앙을 두 번 탭 하면 옷장에 등록합니다.",
                        korColor, korType, korPattern
                );
                tts.speak(prompt, TextToSpeech.QUEUE_FLUSH, null, "RESULT_PROMPT");
            }
        });

        // --- 5) 더블탭 제스처로 DB에 저장 ---
        //    (repository 초기화가 필요하다면 init 코드 추가)
        repository = new ClothesRepository(this);
        detector = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onDoubleTap(MotionEvent e) {
                // imagePath, descriptionText 등의 필드도 함께 저장
                repository.insertClothes(imagePath, descriptionText);
                tts.speak("옷이 내 옷장에 등록되었습니다.", TextToSpeech.QUEUE_FLUSH, null, "REGISTERED");
                finish();
                return true;
            }
        });
        // 화면 터치 이벤트를 제스처 디텍터에 전달
        findViewById(R.id.recognition_root).setOnTouchListener((v, e) -> {
            detector.onTouchEvent(e);
            return true;
        });
    }

    @Override
    protected void onDestroy() {
        if (tts != null) {
            tts.shutdown();
            tts = null;
        }
        super.onDestroy();
    }

    // ================================================
    // === “원본(English/hex) → 한글/기본값” 매핑 함수들  ===
    // ================================================

    /**
     * hex 문자열(예: "#677694")을 받아서
     * 밝기/색상 우위 조건에 따라 흰/검/빨/초/파/회색 중 하나로 바꿔준다.
     * 예외처리: parse 실패 시 “알 수 없음” 반환.
     */
    private String mapColorToKorean(String hex) {
        // 1) hex → ARGB int
        int colorInt = Color.parseColor(hex);

        // 2) Lab 배열로 변환
        double[] lab = new double[3];
        ColorUtils.colorToLAB(colorInt, lab);

        // 3) 프로토타입 Lab 값들과 한글 이름 정의
        double[][] prototypes = {
                {   0.0,   0.0,   0.0},  // 검정
                { 100.0,   0.0,   0.0},  // 흰색
                {  53.2,  80.1,  67.2},  // 빨강
                {  97.1, -21.6,  94.5},  // 노랑
                {  60.3, -31.4,  48.4},  // 초록
                {  32.3,  79.2, -107.9}, // 파랑
                {  60.3,  98.2, -60.8},  // 분홍
                {  54.8,  75.0, -3.1},   // 주황
                {  75.1, -0.1,  -79.1},  // 보라
                {  53.6,  0.0,    0.0}   // 회색 (중간 그레이)
        };
        String[] names = {
                "검정색","흰색","빨간색","노란색",
                "초록색","파란색","분홍색","주황색",
                "보라색","하늘색"
        };

        // 4) ΔE(CIE76) 로 최소값을 찾기
        int best = 0;
        double minDeltaE = Double.MAX_VALUE;
        for (int i = 0; i < prototypes.length; i++) {
            double dL = lab[0] - prototypes[i][0];
            double da = lab[1] - prototypes[i][1];
            double db = lab[2] - prototypes[i][2];
            double deltaE = Math.sqrt(dL*dL + da*da + db*db);
            if (deltaE < minDeltaE) {
                minDeltaE = deltaE;
                best = i;
            }
        }
        return names[best];
    }

    /**
     * 영어 의류 종류(type)를 받아서 한글로 바꿔주는 매핑.
     * 서버 → "shirt", "pants", "dress", "top", "sleeve" 등으로 보낸다고 가정.
     */
    private String mapTypeToKorean(String en) {
        if (en == null) return "알 수 없음";
        switch (en.trim().toLowerCase()) {
            case "shirt":    return "셔츠";
            case "pants":    return "바지";
            case "dress":    return "드레스";
            case "top":      return "상의";
            case "sleeve":   return "셔츠";
            case "jacket":   return "자켓";
            case "skirt":    return "치마";
            // ↓ 필요에 따라 더 추가 가능
            default:         return "기타";
        }
    }

    /**
     * 영어 패턴(pattern)을 받아서 한글로 바꿔주는 매핑.
     * 서버 → "none", "striped", "polka-dot", "plaid" 등으로 보낸다고 가정.
     */
    private String mapPatternToKorean(String en) {
        if (en == null) return "알 수 없음";
        switch (en.trim().toLowerCase()) {
            case "none":       return "없음";
            case "striped":    return "줄무늬";
            case "polka-dot":  return "도트무늬";
            case "plaid":      return "체크무늬";
            case "floral":     return "꽃무늬";
            // ↓ 필요에 따라 더 추가 가능
            default:           return "기타";
        }
    }
}
