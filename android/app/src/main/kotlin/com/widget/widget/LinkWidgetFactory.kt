package com.widget.widget

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject
import java.util.ArrayList

class LinkWidgetFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    private var linkList: List<JSONObject> = ArrayList()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        try {
            val sharedPref = context.getSharedPreferences("widget_data", Context.MODE_PRIVATE)
            val jsonStr = sharedPref.getString("links", "[]") ?: "[]"
            
            val jsonArray = JSONArray(jsonStr)
            val list = ArrayList<JSONObject>()
            for (i in 0 until jsonArray.length()) {
                list.add(jsonArray.getJSONObject(i))
            }
            linkList = list
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        linkList = ArrayList()
    }

    override fun getCount(): Int = linkList.size

    override fun getViewAt(position: Int): RemoteViews {
        if (position >= linkList.size) {
            return RemoteViews(context.packageName, R.layout.widget_item)
        }

        val views = RemoteViews(context.packageName, R.layout.widget_item)

        try {
            val item = linkList[position]
            val title = item.optString("title", "No Title")
            val url = item.optString("url", "")
            val lowerUrl = url.lowercase()

            val iconRes = when {
                lowerUrl.contains("youtube") || lowerUrl.contains("youtu.be") -> R.drawable.youtube
                lowerUrl.contains("github") -> R.drawable.github
                lowerUrl.contains("linkedin") -> R.drawable.linkedin
                lowerUrl.contains("leetcode") -> R.drawable.leetcode
                lowerUrl.contains("instagram") -> R.drawable.instagram
                else -> R.drawable.link
            }

            val bgColor = when {
                lowerUrl.contains("youtube") || lowerUrl.contains("youtu.be") ->
                    android.graphics.Color.parseColor("#de0000")

                lowerUrl.contains("github") ->
                    android.graphics.Color.parseColor("#000000")

                lowerUrl.contains("linkedin") ->
                    android.graphics.Color.parseColor("#006de1")

                lowerUrl.contains("leetcode") ->
                    android.graphics.Color.parseColor("#ec9c08")

                lowerUrl.contains("instagram") ->
                    android.graphics.Color.parseColor("#df088d")

                else ->
                    android.graphics.Color.parseColor("#1A1A1A")
            }

            views.setInt(
                R.id.widget_item_root,
                "setBackgroundColor",
                bgColor
            )

            views.setImageViewResource(
                R.id.widgetItemIcon,
                iconRes
            )

            views.setTextViewText(
                R.id.widgetItemText,
                title
            )

            val fillInIntent = Intent().apply {
                val extras = Bundle()
                extras.putString("EXTRA_URL", url)
                putExtras(extras)
                data = Uri.parse("study://link/$position")
            }

            views.setOnClickFillInIntent(R.id.widget_item_root, fillInIntent)

        } catch (e: Exception) {
            e.printStackTrace()
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}
