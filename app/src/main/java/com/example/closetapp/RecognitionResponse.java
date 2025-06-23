package com.example.closetapp;

public class RecognitionResponse {
    private String color;
    private String type;
    private String pattern;

    private String summary;
    private String description;

    public RecognitionResponse(String color, String type, String pattern, String description) {
        this.color       = color;
        this.type        = type;
        this.pattern     = pattern;
        this.description = description;
    }

    public String getColor() {
        return color;
    }
    public void setColor(String color) {
        this.color = color;
    }

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public String getPattern() {
        return pattern;
    }
    public void setPattern(String pattern) {
        this.pattern = pattern;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }
}
