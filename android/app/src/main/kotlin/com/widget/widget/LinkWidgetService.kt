package com.widget.widget

import android.content.Intent
import android.widget.RemoteViewsService

class LinkWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return LinkWidgetFactory(this.applicationContext, intent)
    }
}
