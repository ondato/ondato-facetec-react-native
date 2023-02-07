package com.reactnativefacetec

import android.app.AlertDialog
import android.content.Context
import android.media.AudioManager
import android.media.MediaPlayer
import android.util.Log
import android.view.ContextThemeWrapper
import android.widget.RelativeLayout
import androidx.lifecycle.ViewModelProvider
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facetec.sdk.FaceTecSDK
import com.facetec.sdk.FaceTecVocalGuidanceCustomization
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.nio.charset.StandardCharsets

class FaceTecUtilities(private val facetecFragment: FaceTecFragment) {
  private var vocalGuidanceOnPlayer: MediaPlayer? = null
  private var vocalGuidanceOffPlayer: MediaPlayer? = null
  private val viewModel: FaceTecViewModel

  fun updateStatus(state: FaceTecState) {
    val data: WritableMap = Arguments.createMap()

    data.putString(
      "status",
      when (state.status) {
        (FaceTecStatus.DORMANT) -> "Not ready"
        (FaceTecStatus.INITIALIZED) -> "Ready"
        (FaceTecStatus.SUCCEEDED) -> "Succeeded"
        (FaceTecStatus.FAILED) -> "Failed"
        (FaceTecStatus.CANCELLED) -> "Cancelled"
        else -> "Unknown"
      }
    )

    if (state.message != null)
      data.putString("message", state.message)
    if (state.load != null)
      data.putString("load", state.load)


    viewModel.getReactContext().value?.let { FaceTecModule.sendEvent(it, "onUpdate", data) }
  }

  fun fadeInMainUI() {
    facetecFragment.requireActivity().runOnUiThread {
      val contentLayout =
        facetecFragment.requireActivity().findViewById<RelativeLayout>(R.id.contentLayout)
      contentLayout.animate().alpha(1f).duration = 600
    }
  }

  fun handleErrorGettingServerSessionToken() {
    Log.d(
      "ReactNativeFaceTec",
      "Session could not be started due to an unexpected issue during the network request."
    )
  }

  fun setUpVocalGuidancePlayers() {
    vocalGuidanceOnPlayer = MediaPlayer.create(facetecFragment.context, R.raw.vocal_guidance_on)
    vocalGuidanceOffPlayer =
      MediaPlayer.create(facetecFragment.context, R.raw.vocal_guidance_off)
  }

  fun setVocalGuidanceMode(mode: VocalGuidanceMode?) {
    val currentCustomization = viewModel.getCustomization().value

    if (isDeviceMuted) {
      val alertDialog = AlertDialog.Builder(
        ContextThemeWrapper(
          facetecFragment.context,
          android.R.style.Theme_Holo_Light
        )
      ).create()
      alertDialog.setMessage("Vocal Guidance is disabled when the device is muted")
      alertDialog.setButton(
        AlertDialog.BUTTON_NEUTRAL, "OK"
      ) { dialog, _ -> dialog.dismiss() }
      alertDialog.show()
      return
    }
    if (vocalGuidanceOnPlayer!!.isPlaying || vocalGuidanceOffPlayer!!.isPlaying) {
      return
    }
    if (currentCustomization != null) {
      facetecFragment.requireActivity().runOnUiThread {
        when (mode) {
          VocalGuidanceMode.MINIMAL -> {
            vocalGuidanceOnPlayer!!.start()
            currentCustomization.vocalGuidanceCustomization.mode =
              FaceTecVocalGuidanceCustomization.VocalGuidanceMode.MINIMAL_VOCAL_GUIDANCE
          }
          VocalGuidanceMode.FULL -> {
            vocalGuidanceOnPlayer!!.start()
            currentCustomization.vocalGuidanceCustomization.mode =
              FaceTecVocalGuidanceCustomization.VocalGuidanceMode.FULL_VOCAL_GUIDANCE
          }
          else -> {
            //vocalGuidanceOffPlayer!!.stop();
            currentCustomization.vocalGuidanceCustomization.mode =
              FaceTecVocalGuidanceCustomization.VocalGuidanceMode.NO_VOCAL_GUIDANCE

          }
        }
        setVocalGuidanceSoundFiles(mode, viewModel)
        FaceTecSDK.setCustomization(currentCustomization)
      }
    }
  }

  private val isDeviceMuted: Boolean
    get() {
      val audio =
        facetecFragment.requireActivity().getSystemService(Context.AUDIO_SERVICE) as AudioManager
      return audio.getStreamVolume(AudioManager.STREAM_MUSIC) == 0
    }

  companion object {
    fun setAppTheme(viewModel: FaceTecViewModel) {
      Log.d("THEME", "This is the theme ${viewModel.getCustomization().value.toString()}")
      FaceTecSDK.setCustomization(viewModel.getCustomization().value)
      FaceTecSDK.setLowLightCustomization(viewModel.getCustomization().value)
      FaceTecSDK.setDynamicDimmingCustomization(viewModel.getCustomization().value)
    }

    fun setVocalGuidanceSoundFiles(mode: VocalGuidanceMode?, viewModel: FaceTecViewModel) {
      val currentCustomization = viewModel.getCustomization().value

      if (currentCustomization != null) {
        currentCustomization.vocalGuidanceCustomization.pleaseFrameYourFaceInTheOvalSoundFile =
          R.raw.please_frame_your_face_sound_file
        currentCustomization.vocalGuidanceCustomization.pleaseMoveCloserSoundFile =
          R.raw.please_move_closer_sound_file
        currentCustomization.vocalGuidanceCustomization.pleaseRetrySoundFile =
          R.raw.please_retry_sound_file
        currentCustomization.vocalGuidanceCustomization.uploadingSoundFile =
          R.raw.uploading_sound_file
        currentCustomization.vocalGuidanceCustomization.facescanSuccessfulSoundFile =
          R.raw.facescan_successful_sound_file
        currentCustomization.vocalGuidanceCustomization.pleasePressTheButtonToStartSoundFile =
          R.raw.please_press_button_sound_file
        currentCustomization.vocalGuidanceCustomization.mode = when (mode) {
          VocalGuidanceMode.MINIMAL ->
            FaceTecVocalGuidanceCustomization.VocalGuidanceMode.MINIMAL_VOCAL_GUIDANCE
          VocalGuidanceMode.FULL ->
            FaceTecVocalGuidanceCustomization.VocalGuidanceMode.FULL_VOCAL_GUIDANCE
          else ->
            FaceTecVocalGuidanceCustomization.VocalGuidanceMode.NO_VOCAL_GUIDANCE

        }
      }
    }

    fun setOCRLocalization(context: Context) {
      // Set the strings to be used for group names, field names, and placeholder texts for the FaceTec ID Scan User OCR Confirmation Screen.
      // DEVELOPER NOTE: For this demo, we are using the template json file, 'FaceTec_OCR_Customization.json,' as the parameter in calling this API.
      // For the configureOCRLocalization API parameter, you may use any object that follows the same structure and key naming as the template json file, 'FaceTec_OCR_Customization.json'.
      try {
        val `is` = context.assets.open("FaceTec_OCR_Customization.json")
        val size = `is`.available()
        val buffer = ByteArray(size)
        `is`.read(buffer)
        `is`.close()
        val ocrLocalizationJSONString = String(buffer, StandardCharsets.UTF_8)
        val ocrLocalizationJSON = JSONObject(ocrLocalizationJSONString)
        FaceTecSDK.configureOCRLocalization(ocrLocalizationJSON)
      } catch (ex: IOException) {
        ex.printStackTrace()
      } catch (ex: JSONException) {
        ex.printStackTrace()
      }
    }
  }

  init {
    setUpVocalGuidancePlayers()
    viewModel = ViewModelProvider(facetecFragment.requireActivity()).get(
      FaceTecViewModel::class.java
    )
    viewModel.getVocalGuidanceMode()
      .observe(facetecFragment.requireActivity()) { mode: VocalGuidanceMode? ->
        setVocalGuidanceMode(mode)
      }
  }
}
