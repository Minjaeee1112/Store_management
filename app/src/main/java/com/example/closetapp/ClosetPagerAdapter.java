package com.example.closetapp;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.io.File;
import java.util.List;

public class ClosetPagerAdapter extends RecyclerView.Adapter<ClosetPagerAdapter.ViewHolder>{
    private final List<ClothesItem> clothesList;

    public ClosetPagerAdapter(List<ClothesItem> clothesList) {
        this.clothesList = clothesList;
    }

    @NonNull
    @Override
    public ClosetPagerAdapter.ViewHolder onCreateViewHolder(
            @NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_closet_page, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(
            @NonNull ClosetPagerAdapter.ViewHolder holder, int position) {
        ClothesItem item = clothesList.get(position);

        // imagePath가 로컬 파일 경로일 때
        File imgFile = new File(item.getImagePath());
        if (imgFile.exists()) {
            Bitmap bmp = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
            holder.ivClothes.setImageBitmap(bmp);
        } else {
            holder.ivClothes.setImageResource(R.drawable.ic_placeholder);
            // 없으면 placeholder 아이콘을 res/drawable/ic_placeholder.png 등에 추가하세요.
        }
    }

    @Override
    public int getItemCount() {
        return clothesList.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivClothes;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivClothes = itemView.findViewById(R.id.ivClothes);
        }
    }

}
