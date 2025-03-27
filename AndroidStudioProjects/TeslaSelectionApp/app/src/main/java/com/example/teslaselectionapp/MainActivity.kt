package com.example.teslaselectionapp

import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.snackbar.Snackbar

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        Log.e("MainActivity", "onCreate")

        // ViewPager2 設定
        val viewPager2 = findViewById<ViewPager2>(R.id.viewPager2)
        val adapter = ViewPagerAdapter(supportFragmentManager, this.lifecycle)
        viewPager2.adapter = adapter
        viewPager2.offscreenPageLimit = 1

        // 綁定 UI 按鈕
        val btnToast = findViewById<Button>(R.id.btn_toast)
        val btnSnackbar = findViewById<Button>(R.id.btn_snackbar)
        val btnAlert = findViewById<Button>(R.id.btn_alert)
        val btnListDialog = findViewById<Button>(R.id.btn_list_dialog)
        val btnSingleChoice = findViewById<Button>(R.id.btn_single_choice)

        // 1. Toast
        btnToast.setOnClickListener {
            Toast.makeText(this, "Tesla 是全球電動車領導者！", Toast.LENGTH_SHORT).show()
        }

        // 2. Snackbar（帶按鈕）
        btnSnackbar.setOnClickListener { view ->
            val snackbar = Snackbar.make(view, "想了解更多 Tesla 嗎？", Snackbar.LENGTH_LONG)
            snackbar.setAction("前往官網") {
                val url = "https://www.tesla.com/"
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                startActivity(intent)
            }
            snackbar.show()
        }

        // 3. 按鈕式 AlertDialog
        btnAlert.setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle("Tesla Model S")
                .setMessage("Tesla Model S 是一款豪華電動車，擁有超長續航和極速加速性能！")
                .setPositiveButton("確定") { dialog, _ -> dialog.dismiss() }
                .show()
        }

        // 4. 列表式 AlertDialog（Tesla 車型選擇）
        btnListDialog.setOnClickListener {
            val carModels = arrayOf("Model S", "Model 3", "Model X", "Model Y", "Cybertruck")
            AlertDialog.Builder(this)
                .setTitle("選擇 Tesla 車型")
                .setItems(carModels) { _, which ->
                    Toast.makeText(this, "你選擇了 ${carModels[which]}", Toast.LENGTH_SHORT).show()
                }
                .show()
        }

        // 5. 單選式 AlertDialog（最喜歡的 Tesla 車型）
        btnSingleChoice.setOnClickListener {
            val carModels = arrayOf("Model S", "Model 3", "Model X", "Model Y", "Cybertruck")
            var selectedModel = 0  // 預設選項
            AlertDialog.Builder(this)
                .setTitle("最喜歡的 Tesla 車型")
                .setSingleChoiceItems(carModels, selectedModel) { _, which ->
                    selectedModel = which
                }
                .setPositiveButton("確定") { _, _ ->
                    Toast.makeText(this, "你最喜歡 ${carModels[selectedModel]}", Toast.LENGTH_SHORT).show()
                }
                .setNegativeButton("取消", null)
                .show()
        }
    }
}
