package com.example.locket_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class LocketHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val size = widgetData.getString("widgetSize", "Small") ?: "Small"

            val themeColor = getColorSafe(
                widgetData,
                "widgetThemeColor",
                Color.rgb(255, 215, 64)
            )

            val textColor = if (isLightColor(themeColor)) Color.BLACK else Color.WHITE
            val mutedTextColor = withAlpha(textColor, 178)

            val caption = widgetData.getString("widgetCaption", "saturday afternoon")
                ?: "saturday afternoon"
            val username = widgetData.getString("widgetUsername", "") ?: ""
            val timestamp = widgetData.getString("widgetTimestamp", "2m") ?: "2m"
            val imagePath = widgetData.getString("widgetImagePath", null)
            val avatarImagePath = widgetData.getString("widgetAvatarImagePath", null)
            val hasImage = imagePath != null && File(imagePath).exists()
            val contentTextColor = if (hasImage) Color.WHITE else textColor
            val contentMutedTextColor = if (hasImage) Color.WHITE else mutedTextColor

            val views = RemoteViews(context.packageName, R.layout.locket_home_widget).apply {
                setTextColor(R.id.widget_timestamp, contentMutedTextColor)
                setTextColor(R.id.widget_caption, contentTextColor)
                setTextViewText(R.id.widget_timestamp, timestamp)
                setTextViewText(R.id.widget_caption, caption)
                setTextViewText(R.id.widget_avatar_initials, initialsFor(username))
                setLatestImage(context, imagePath, themeColor)
                setAvatarImage(avatarImagePath)
                applySize(context, size)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun getColorSafe(
        prefs: SharedPreferences,
        key: String,
        defaultValue: Int
    ): Int {
        return try {
            when (val value = prefs.all[key]) {
                is Int -> value
                is Long -> value.toInt()
                is Number -> value.toInt()
                is String -> value.toIntOrNull() ?: defaultValue
                else -> defaultValue
            }
        } catch (e: Exception) {
            defaultValue
        }
    }

    private fun RemoteViews.applySize(context: Context, size: String) {
        when (size) {
            "Large" -> {
                setViewPadding(R.id.widget_content, dp(context, 14), dp(context, 12), dp(context, 14), dp(context, 14))
                setTextViewTextSize(R.id.widget_timestamp, TypedValue.COMPLEX_UNIT_SP, 11f)
                setTextViewTextSize(R.id.widget_caption, TypedValue.COMPLEX_UNIT_SP, 18f)
                setTextViewTextSize(R.id.widget_avatar_initials, TypedValue.COMPLEX_UNIT_SP, 15f)
            }

            "Medium" -> {
                setViewPadding(R.id.widget_content, dp(context, 12), dp(context, 11), dp(context, 12), dp(context, 13))
                setTextViewTextSize(R.id.widget_timestamp, TypedValue.COMPLEX_UNIT_SP, 10f)
                setTextViewTextSize(R.id.widget_caption, TypedValue.COMPLEX_UNIT_SP, 16f)
                setTextViewTextSize(R.id.widget_avatar_initials, TypedValue.COMPLEX_UNIT_SP, 14f)
            }

            else -> {
                setViewPadding(R.id.widget_content, dp(context, 9), dp(context, 8), dp(context, 9), dp(context, 10))
                setTextViewTextSize(R.id.widget_timestamp, TypedValue.COMPLEX_UNIT_SP, 9f)
                setTextViewTextSize(R.id.widget_caption, TypedValue.COMPLEX_UNIT_SP, 13f)
                setTextViewTextSize(R.id.widget_avatar_initials, TypedValue.COMPLEX_UNIT_SP, 13f)
            }
        }
    }

    private fun RemoteViews.setLatestImage(context: Context, imagePath: String?, themeColor: Int) {
        val cornerRadius = dp(context, 34).toFloat()

        if (imagePath == null || !File(imagePath).exists()) {
            setImageViewBitmap(R.id.widget_image, roundedColorBitmap(themeColor, cornerRadius))
            setViewVisibility(R.id.widget_image, View.VISIBLE)
            return
        }

        val bitmap = decodeSampledBitmap(imagePath, 900, 900)
        if (bitmap == null) {
            setImageViewBitmap(R.id.widget_image, roundedColorBitmap(themeColor, cornerRadius))
            setViewVisibility(R.id.widget_image, View.VISIBLE)
            return
        }

        setImageViewBitmap(R.id.widget_image, roundCorners(bitmap, cornerRadius))
        setViewVisibility(R.id.widget_image, View.VISIBLE)
    }

    private fun RemoteViews.setAvatarImage(avatarImagePath: String?) {
        if (avatarImagePath == null || !File(avatarImagePath).exists()) {
            setViewVisibility(R.id.widget_avatar_image, View.GONE)
            setViewVisibility(R.id.widget_avatar_initials, View.VISIBLE)
            return
        }

        val bitmap = decodeSampledBitmap(avatarImagePath, 160, 160)
        if (bitmap == null) {
            setViewVisibility(R.id.widget_avatar_image, View.GONE)
            setViewVisibility(R.id.widget_avatar_initials, View.VISIBLE)
            return
        }

        setImageViewBitmap(R.id.widget_avatar_image, circleCrop(bitmap))
        setViewVisibility(R.id.widget_avatar_image, View.VISIBLE)
        setViewVisibility(R.id.widget_avatar_initials, View.GONE)
    }

    private fun decodeSampledBitmap(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        BitmapFactory.decodeFile(path, options)

        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)
        options.inJustDecodeBounds = false
        return BitmapFactory.decodeFile(path, options)
    }

    private fun calculateInSampleSize(
        options: BitmapFactory.Options,
        reqWidth: Int,
        reqHeight: Int
    ): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            var halfHeight = height / 2
            var halfWidth = width / 2

            while (halfHeight / inSampleSize >= reqHeight &&
                halfWidth / inSampleSize >= reqWidth
            ) {
                inSampleSize *= 2
            }
        }

        return inSampleSize
    }

    private fun dp(context: Context, value: Int): Int {
        return (value * context.resources.displayMetrics.density).toInt()
    }

    private fun roundCorners(bitmap: Bitmap, radius: Float): Bitmap {
        val output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = BitmapShader(bitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        }
        val rect = RectF(0f, 0f, bitmap.width.toFloat(), bitmap.height.toFloat())
        canvas.drawRoundRect(rect, radius, radius, paint)
        return output
    }

    private fun roundedColorBitmap(color: Int, radius: Float): Bitmap {
        val size = 900
        val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
        }
        val rect = RectF(0f, 0f, size.toFloat(), size.toFloat())
        canvas.drawRoundRect(rect, radius, radius, paint)
        return output
    }

    private fun circleCrop(bitmap: Bitmap): Bitmap {
        val size = minOf(bitmap.width, bitmap.height)
        val x = (bitmap.width - size) / 2
        val y = (bitmap.height - size) / 2
        val square = Bitmap.createBitmap(bitmap, x, y, size, size)
        val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = BitmapShader(square, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        }
        val radius = size / 2f
        canvas.drawCircle(radius, radius, radius, paint)
        return output
    }

    private fun initialsFor(name: String): String {
        val cleanName = name.replace("@", " ").trim()
        val parts = cleanName.split(Regex("\\s+")).filter { it.isNotBlank() }

        if (parts.isEmpty()) {
            return "?"
        }

        return parts.take(2).joinToString("") { it.first().uppercase() }
    }

    private fun isLightColor(color: Int): Boolean {
        val red = Color.red(color)
        val green = Color.green(color)
        val blue = Color.blue(color)
        return (0.299 * red + 0.587 * green + 0.114 * blue) > 186
    }

    private fun withAlpha(color: Int, alpha: Int): Int {
        return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))
    }
}
