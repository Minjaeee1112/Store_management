package com.example.closetapp;

import android.util.Log;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

public class VisionApiClient {
    /**
     * API 호출 결과를 비동기로 받아볼 콜백 인터페이스
     */
    public interface RecognitionCallback {
        void onSuccess(RecognitionResponse res);
        void onFailure(Throwable t);
    }

    private final OkHttpClient client = new OkHttpClient();

    /** 서버의 인식 엔드포인트 URL (포트, 호스트는 실제 환경에 맞게 변경) */
    private static final String ENDPOINT_URL = "http://172.30.1.21:8080/api/recognize";

    /**
     * JPEG 바이트 배열을 받아서 Vision 서버에 전송하고,
     * 결과 JSON을 파싱해서 RecognitionCallback으로 반환합니다.
     */
    public void recognizeClothing(byte[] jpeg, RecognitionCallback cb, String savedImagePath ) {
        // 1) 파일 바디 생성 (image/jpeg)
        RequestBody fileBody = RequestBody.create(jpeg, MediaType.get("image/jpeg"));

        // 2) multipart/form-data 바디 생성
        MultipartBody body = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("image", "capture.jpg", fileBody)
                .build();

        // 3) 요청 빌드
        Request request = new Request.Builder()
                .url(ENDPOINT_URL)
                .post(body)
                .build();

        // 4) 비동기 호출
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                // 네트워크 실패 등
                Log.e("VisionApiClient", "API 호출 실패", e);
                cb.onFailure(e);
            }

            @Override
            public void onResponse(Call call, Response res) throws IOException {
                if (!res.isSuccessful()) {
                    // HTTP 에러
                    Log.e("VisionApiClient", "API 응답 코드 실패: " + res.code());
                    cb.onFailure(new IOException("Unexpected " + res));
                    return;
                }

                // 5) 본문(JSON) 파싱
                try {
                    String json = res.body().string();
                    JSONObject obj = new JSONObject(json);

                    RecognitionResponse rr = new RecognitionResponse(
                            obj.getString("color"),
                            obj.getString("type"),
                            obj.getString("pattern"),
                            obj.optString("description", "")  // description이 없으면 빈 문자열
                    );

                    // 6) 성공 콜백
                    cb.onSuccess(rr);

                } catch (JSONException e) {
                    // JSON 파싱 에러
                    cb.onFailure(e);
                }
            }
        });
    }
}
