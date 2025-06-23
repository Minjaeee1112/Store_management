package com.example.closetapp;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class ClothesDatabaseHelper extends SQLiteOpenHelper {
    private static final String DB_NAME    = "clothes.db";
    private static final int    DB_VERSION = 1;

    public ClothesDatabaseHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(
                "CREATE TABLE clothes (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "imagePath TEXT, " +
                        "resultText TEXT" +
                        ")"
        );
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS clothes");
        onCreate(db);
    }
}
