package com.example.closetapp;

public class ClothesItem {
    private long id;
    private String imagePath;
    private String description;

    public ClothesItem(long id, String imagePath, String description) {
        this.id = id;
        this.imagePath = imagePath;
        this.description = description;
    }

    public long getId() {
        return id;
    }

    public String getImagePath() {
        return imagePath;
    }

    public String getDescription() {
        return description;
    }
}
