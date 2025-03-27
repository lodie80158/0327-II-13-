package com.example.teslaselectionapp

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.viewpager2.adapter.FragmentStateAdapter

class ViewPagerAdapter (
    fm:FragmentManager,
    lifecycle:Lifecycle
    ,):FragmentStateAdapter(fm,lifecycle){

    override fun getItemCount(): Int = 3  // 總共有 3 個 Fragment

    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> FirstFragment()   // 第一個頁面：Tesla 車型介紹
            1 -> SecondFragment()     // 第二個頁面：電池與充電技術
            else -> ThirdFragment() // 第三個頁面：自動駕駛與智慧系統
        }
    }
    }