package com.reactnativefacetec

import android.util.Log
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments
import com.facebook.react.modules.core.DeviceEventManagerModule

class FaceTecModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName() = "FaceTecModule"

  companion object {
    fun sendEvent(reactContext: ReactContext, eventName: String, params: WritableMap?) {
      reactContext
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        .emit(eventName, params)
    }
  }

  @ReactMethod
  fun addListener(eventName: String) {
    // Set up any upstream listeners or background tasks as necessary
  }

  @ReactMethod
  fun removeListeners(count: Int) {
    // Remove upstream listeners, stop unnecessary background tasks
  }

  @ReactMethod
  fun createEvent(name: String, location: String) {
    Log.d("CalendarModule", "Create event called with name: $name and location: $location")
    val params = Arguments.createMap().apply {
      putString("status", "$name")
      putString("message", "$location")
    }
    sendEvent(reactContext, "onUpdate", params)
  }

}
