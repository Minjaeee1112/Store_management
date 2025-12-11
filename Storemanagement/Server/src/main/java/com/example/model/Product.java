package com.example.model;

public class Product {
    private int id;
    private String name;
    private double price;
    private String description;
    private int stock;
    private String status;
    private String category; // 카테고리 필드 추가
    private byte[] picture; // 사진 필드 추가

    // 기본 생성자
    public Product() {}

    // 6개의 매개변수를 받는 생성자
    public Product(int id, String name, double price, String description, int stock, String status) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.description = description;
        this.stock = stock;
        this.status = status;
    }

    // 모든 필드를 초기화하는 생성자
    public Product(int id, String name, double price, String description, int stock, String status, String category, byte[] picture) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.description = description;
        this.stock = stock;
        this.status = status;
        this.category = category;
        this.picture = picture;
    }

    // Getter and Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public byte[] getPicture() { return picture; }
    public void setPicture(byte[] picture) { this.picture = picture; }
}
