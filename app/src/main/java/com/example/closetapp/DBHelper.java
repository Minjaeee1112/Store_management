package com.example.closetapp;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DBHelper extends SQLiteOpenHelper  {
    private static final String DB_NAME    = "closet.db";
    private static final int    DB_VERSION = 1;

    public DBHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // AUTOINCREMENT 포함한 테이블 생성
        String sql =
                "CREATE TABLE clothes (" +
                        " _id INTEGER PRIMARY KEY AUTOINCREMENT," +
                        " image_path TEXT NOT NULL," +
                        " description TEXT" +
                        ")";
        db.execSQL(sql);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldV, int newV) {
        // 버전 업그레이드 로직 (예: ALTER TABLE)
        if (oldV < newV) {
            db.execSQL("DROP TABLE IF EXISTS clothes");
            onCreate(db);
        }
    }
}
