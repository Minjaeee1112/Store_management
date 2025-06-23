package com.example.closetapp;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.ArrayList;
import java.util.List;
public class ClothesRepository {
    private final SQLiteDatabase db;

    public ClothesRepository(Context ctx) {
        DBHelper helper = new DBHelper(ctx);
        db = helper.getWritableDatabase();
    }

    /** 새로운 row 를 추가(insert)만 하고, 기존 행을 절대 수정하거나 대체하지 않습니다. */
    public long insertClothes(String imagePath, String description) {
        ContentValues cv = new ContentValues();
        cv.put("image_path", imagePath);
        cv.put("description", description);
        return db.insert("clothes", /* nullColumnHack = */ null, cv);
    }

    /** 등록된 모든 옷을 _id 오름차순(등록 순)으로 가져옵니다. */
    public List<ClothesItem> getAllClothes() {
        List<ClothesItem> list = new ArrayList<>();
        try (Cursor c = db.query(
                "clothes",
                null,           // 모든 컬럼
                null, null,     // where 절 없음
                null, null,
                "_id ASC"       // 등록 순서대로
        )) {
            while (c.moveToNext()) {
                long id = c.getLong(c.getColumnIndexOrThrow("_id"));
                String path = c.getString(c.getColumnIndexOrThrow("image_path"));
                String desc = c.getString(c.getColumnIndexOrThrow("description"));
                list.add(new ClothesItem(id, path, desc));
            }
        }
        return list;
    }

    public void deleteClothes(long id) {
        db.delete("clothes", "_id=?", new String[]{ String.valueOf(id) });
    }

    public boolean isClothesRegistered(String query) {

        return true;
    }
}
