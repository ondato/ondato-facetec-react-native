package com.reactnativefacetec

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.facebook.react.bridge.ReactContext
import com.facetec.sdk.FaceTecCustomization

class FaceTecViewModel : ViewModel() {
  private val vocalGuidanceMode = MutableLiveData<VocalGuidanceMode>()
  private val utils = MutableLiveData<FaceTecUtilities>()
  private val latestProcessor = MutableLiveData<FaceTecProcessor>()
  private val deviceKeyIdentifier = MutableLiveData<String>()
  private val productionKeyText = MutableLiveData<String>()
  private val faceScanEncryptionKey = MutableLiveData<String>()
  private val sessionToken = MutableLiveData<String>()
  private val baseURL = MutableLiveData<String>()
  private val reactContext = MutableLiveData<ReactContext>()
  private val customization = MutableLiveData<FaceTecCustomization>()

  fun getVocalGuidanceMode(): LiveData<VocalGuidanceMode> = vocalGuidanceMode
  fun getUtils(): LiveData<FaceTecUtilities> = utils
  fun getLatestProcessor(): LiveData<FaceTecProcessor> = latestProcessor
  fun getDeviceKeyIdentifier(): LiveData<String> = deviceKeyIdentifier
  fun getSessionToken(): LiveData<String> = sessionToken
  fun getProductionKeyText(): LiveData<String> = productionKeyText
  fun getFaceScanEncryptionKey(): LiveData<String> = faceScanEncryptionKey
  fun getBaseURL(): LiveData<String> = baseURL
  fun getReactContext(): LiveData<ReactContext> = reactContext
  fun getCustomization(): LiveData<FaceTecCustomization> = customization

  fun setVocalGuidanceMode(mode: VocalGuidanceMode) {
    vocalGuidanceMode.postValue(mode)
  }

  fun setUtils(u: FaceTecUtilities) {
    utils.postValue(u);
  }

  fun setLatestProcessor(processor: FaceTecProcessor) {
    latestProcessor.postValue(processor)
  }

  fun setDeviceKeyIdentifier(key: String) {
    deviceKeyIdentifier.postValue(key)
  }

  fun setSessionToken(key: String) {
    sessionToken.postValue(key)
  }

  fun setProductionKeyText(key: String) {
    productionKeyText.postValue(key)
  }

  fun setFaceScanEncryptionKey(key: String) {
    faceScanEncryptionKey.postValue(key)
  }

  fun setReactContext(context: ReactContext) {
    reactContext.postValue(context)
  }

  fun setCustomization(c: FaceTecCustomization) {
    customization.postValue(c)
  }
}
