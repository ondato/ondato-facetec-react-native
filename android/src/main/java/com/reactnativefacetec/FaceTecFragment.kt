package com.reactnativefacetec

import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.facetec.sdk.FaceTecSDK.InitializeCallback
import android.util.Log
import com.facetec.sdk.FaceTecSDK
import androidx.fragment.app.Fragment
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Request
import java.io.IOException
import kotlin.Throws
import okhttp3.Response
import org.json.JSONObject
import org.json.JSONException
import java.util.*
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.suspendCoroutine

class FaceTecFragment : Fragment(R.layout.activity_main), CoroutineScope {
  private var viewModel: FaceTecViewModel? = null
  private var job: Job = Job()
  override val coroutineContext: CoroutineContext
    get() = Dispatchers.Main + job

  private suspend fun startProcessor() {
    var sessionToken: String = viewModel!!.getSessionToken().value ?: "";

    if (sessionToken.isBlank()) {
      Log.d("ReactNativeFaceTec", "Session token was not provided")
      sessionToken = getSessionToken()
      viewModel!!.setSessionToken(sessionToken)
    }

    if (sessionToken.isNotBlank()) {
      Log.d("ReactNativeFaceTec", "Provided session token: $sessionToken")
      viewModel?.getUtils()?.value?.updateStatus(FaceTecState(FaceTecStatus.INITIALIZED))

      viewModel!!.setLatestProcessor(
        FaceTecProcessor(
          activity,
          sessionToken,
        )
      )
    } else {
      viewModel?.getUtils()?.value?.updateStatus(FaceTecState(FaceTecStatus.FAILED, "Could not retrieve session token"))
    }
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    viewModel = ViewModelProvider(requireActivity()).get(FaceTecViewModel::class.java)

    if (Objects.isNull(viewModel!!.getUtils().value)) {
      viewModel!!.setUtils(FaceTecUtilities(this))
    }
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    // Initialize FaceTec SDK
    FaceTecConfig.initializeFaceTecSDK(
      context,
      viewModel?.getProductionKeyText()?.value,
      viewModel?.getDeviceKeyIdentifier()?.value,
      viewModel?.getFaceScanEncryptionKey()?.value,
      object : InitializeCallback() {
        override fun onCompletion(successful: Boolean) {
          if (successful) {
            Log.d("ReactNativeFaceTec", "Initialization Successful.")
            launch {
              startProcessor()
            }
          }
        }
      })

    // Set your FaceTec Device SDK Customizations.
    viewModel?.let { FaceTecUtilities.setAppTheme(it) }


    // Set the strings to be used for group names, field names, and placeholder texts for the FaceTec ID Scan User OCR Confirmation Screen.
    FaceTecUtilities.setOCRLocalization(view.context)
  }

  private suspend fun getSessionToken(): String {
    val deviceKeyIdentifier =
      viewModel!!.getDeviceKeyIdentifier().value ?: FaceTecConfig.DeviceKeyIdentifier
    val baseURL = viewModel!!.getBaseURL().value ?: FaceTecConfig.BaseURL

    Log.d("ReactNativeFaceTec", "BaseURL used for getting the session token: $baseURL")

    // Do the network call and handle result
    val request: Request = Request.Builder()
      .header("X-Device-Key", deviceKeyIdentifier)
      .header("User-Agent", FaceTecSDK.createFaceTecAPIUserAgentString(""))
      .url("$baseURL/session-token")
      .get()
      .build()

    return suspendCoroutine { cont ->
      NetworkingHelpers.getApiClient().newCall(request).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) {
          e.printStackTrace()
          Log.d("ReactNativeFaceTec", "Exception raised while attempting HTTPS call.")

          viewModel?.getUtils()?.value?.updateStatus(
            FaceTecState(
              FaceTecStatus.FAILED,
              "Could not get the FaceTec session token."
            )
          )
          // If this comes from HTTPS cancel call, don't set the sub code to NETWORK_ERROR.
          if (e.message != NetworkingHelpers.OK_HTTP_RESPONSE_CANCELED) {
            viewModel!!.getUtils().value!!.handleErrorGettingServerSessionToken()
          }
        }

        @Throws(IOException::class)
        override fun onResponse(call: Call, response: Response) {
          val responseString = response.body!!.string()
          response.body!!.close()
          try {
            val responseJSON = JSONObject(responseString)
            if (responseJSON.has("sessionToken")) {
              val sessionToken = responseJSON.getString("sessionToken")
              Log.d("ReactNativeFaceTec", "Current session token: $sessionToken")
              cont.resumeWith(Result.success(sessionToken))
            } else {
              viewModel!!.getUtils().value!!.handleErrorGettingServerSessionToken()
            }
          } catch (e: JSONException) {
            e.printStackTrace()
            Log.d(
              "ReactNativeFaceTec",
              "Exception raised while attempting to parse JSON result."
            )
            viewModel?.getUtils()?.value?.updateStatus(
              FaceTecState(
                FaceTecStatus.FAILED,
                "Exception raised while attempting to parse JSON result."
              )
            )
            viewModel!!.getUtils().value!!.handleErrorGettingServerSessionToken()
          }
        }
      })
    }
  }
}
