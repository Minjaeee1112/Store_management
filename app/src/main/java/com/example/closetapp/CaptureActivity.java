package com.example.closetapp;

import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.TextureView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class CaptureActivity extends AppCompatActivity
        implements CameraManager.FrameCallback, VisionApiClient.RecognitionCallback {

    private TextureView textureView;
    private TextView    tvResult;

    private CameraManager    cameraManager;
    private VisionApiClient  visionClient;
    private SpeechManager    speechManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_capture);

        // 뷰 초기화
        textureView = findViewById(R.id.textureView);
        tvResult    = findViewById(R.id.tvResult);

        // 매니저 객체 생성
        cameraManager = new CameraManager(this, textureView, this);
        visionClient  = new VisionApiClient();
        speechManager = new SpeechManager(this);
    }

    @Override
    protected void onStart() {
        super.onStart();
        // TTS 초기화 후 카메라 시작
        speechManager.init();
        cameraManager.startCamera();
    }

    @Override
    protected void onStop() {
        // 카메라와 TTS 해제
        cameraManager.stopCamera();
        speechManager.shutdown();
        super.onStop();
    }

    // === CameraManager.FrameCallback ===
    // 카메라에서 프레임(JPEG 바이트) 캡처될 때마다 호출

        @Override
        public void onFrameCaptured(byte[] jpegBytes) {
            // 1) 파일로 저장
            String path = saveJpegToFile(jpegBytes);
            // 2) 서버에 전송
            visionClient.recognizeClothing(jpegBytes, this, path);
        }

    private String saveJpegToFile(byte[] jpegBytes) {
        return null;
    }


    // === VisionApiClient.RecognitionCallback ===
    // 인식이 성공했을 때
    @Override
    public void onSuccess(RecognitionResponse res) {
        runOnUiThread(() -> {
            // 결과 화면에 출력
            String korColor   = mapColorToKorean(res.getColor());
            String korType    = mapTypeToKorean(res.getType());
            String korPattern = mapPatternToKorean(res.getPattern());

            // 2) 화면에 표시 & TTS
            String text = String.format("색상 : %s\n종류 : %s\n패턴 : %s",
                    korColor, korType, korPattern);
            tvResult.setText(text);
            speechManager.speak(text);
        });
    }

    // 인식에 실패했을 때
    @Override
    public void onFailure(Throwable t) {
        Log.e("CaptureActivity", "인식 실패", t);
        runOnUiThread(() -> {
            speechManager.speak("서버 연결에 실패하였습니다.");
        });
    }

    private String mapColorToKorean(String hex) {
        if (hex == null || hex.length() < 7) {
            return "알 수 없음";
        }

        // parseColor가 실패하면 예외가 날 수 있으니 try-catch
        int c;
        try {
            c = Color.parseColor(hex);
        } catch (Exception e) {
            return "알 수 없음";
        }
        int r = Color.red(c), g = Color.green(c), b = Color.blue(c);

        if (r > 200 && g > 200 && b > 200)           return "흰색";
        if (r < 50 && g < 50 && b < 50)              return "검정색";
        if (r > g && r > b)                          return "빨간색";
        if (g > r && g > b)                          return "초록색";
        if (b > r && b > g)                          return "파란색";
        return "회색";
    }

    /** 영어 종류(type)을 한글로 변환 */
    private String mapTypeToKorean(String en) {
        if (en == null) return "알 수 없음";
        switch (en.toLowerCase()) {
            case "sleeve":    return "소매";
            case "shirt":     return "셔츠";
            case "top":       return "상의";
            case "pants":     return "바지";
            case "dress":     return "드레스";
            default:          return en;
        }
    }

    /** 영어 패턴(pattern)을 한글로 변환 */
    private String mapPatternToKorean(String en) {
        switch (en.toLowerCase()) {
            case "none":      return "무지";
            case "striped":   return "줄무늬";
            case "polka-dot": return "도트무늬";
            case "plaid":     return "체크무늬";
            default:          return en;
        }
    }
}
