package com.example.closetapp;

import android.content.Context;
import android.graphics.ImageFormat;
import android.media.ImageReader;
import android.view.TextureView;
import com.example.closetapp.CameraManager.FrameCallback;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class CameraManager {
    public interface FrameCallback {
        void onFrameCaptured(byte[] jpegBytes);
    }

    private final Context context;
    private final TextureView textureView;
    private final FrameCallback callback;
    private ImageReader imageReader;
    // ... CameraDevice, CaptureSession 등 필드

    public CameraManager(Context ctx, TextureView tv, FrameCallback cb) {
        this.context = ctx;
        this.textureView = tv;
        this.callback = cb;
        setupImageReader();
    }

    private void setupImageReader() {
        imageReader = ImageReader.newInstance(1920, 1080,
                ImageFormat.JPEG, /*maxImages*/2);
        imageReader.setOnImageAvailableListener(reader -> {
            var image = reader.acquireLatestImage();
            var buffer = image.getPlanes()[0].getBuffer();
            byte[] bytes = new byte[buffer.remaining()];
            buffer.get(bytes);
            image.close();
            callback.onFrameCaptured(bytes);
        }, null);
    }

    public void startCamera() {
        // CameraManager.openCamera 등 호출
    }

    public void stopCamera() {
        // 세션 해제, 디바이스 해제
    }


    private String saveJpegToFile(byte[] jpeg) throws IOException {
        File dir = new File(context.getExternalFilesDir(null), "captures");
        if (!dir.exists()) dir.mkdirs();

        String fname = "capture_" + System.currentTimeMillis() + ".jpg";
        File out = new File(dir, fname);
        try (FileOutputStream fos = new FileOutputStream(out)) {
            fos.write(jpeg);
        }
        return out.getAbsolutePath();
    }
}
