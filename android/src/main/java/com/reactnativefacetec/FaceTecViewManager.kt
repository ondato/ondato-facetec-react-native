package com.reactnativefacetec

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.fonts.SystemFonts
import android.os.Build
import android.util.Log
import android.view.Choreographer
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.annotations.ReactPropGroup
import com.facetec.sdk.FaceTecCustomization

class FaceTecViewManager(var reactContext: ReactApplicationContext) :
  ViewGroupManager<FrameLayout?>() {
  private var viewModel: FaceTecViewModel? = null
  private var viewId: Int? = null
  private var propWidth: Int? = null
  private var propHeight: Int? = null

  override fun getName() = REACT_CLASS

  private val activityEventListener =
    object : BaseActivityEventListener() {
      // When the FaceTec SDK is completely done, you receive control back here.
      // Since you have already handled all results in your Processor code, how you proceed here is up to you and how your App works.
      // In general, there was either a Success, or there was some other case where you cancelled out.
      override fun onActivityResult(
        activity: Activity?,
        requestCode: Int,
        resultCode: Int,
        intent: Intent?
      ) {

        Log.d(
          "ReactNativeFaceTec", "onActivityResult: " +
            "\nrequestCode -> $requestCode " +
            "\nresultCode -> $resultCode " +
            "\nintent -> " + intent.toString()
        )

        if (viewModel!!.getLatestProcessor().value == null) {
          return
        }

        viewModel!!.getUtils().value!!.fadeInMainUI()

        // At this point, you have already handled all results in your Processor code.
        val state: FaceTecState? = viewModel!!.getLatestProcessor().value!!.getLastState()

        if (state != null) {
          viewModel!!.getUtils().value!!.updateStatus(state)
        }
      }
    }

  init {
    reactContext.addActivityEventListener(activityEventListener)
  }

  /**
   * Return a FrameLayout which will later hold the Fragment
   */
  public override fun createViewInstance(reactContext: ThemedReactContext): FrameLayout {
    val activity = reactContext.currentActivity as FragmentActivity

    viewModel = ViewModelProvider(activity).get(FaceTecViewModel::class.java)
    viewModel!!.setReactContext(reactContext)

    return FrameLayout(reactContext)
  }

  /**
   * Map the "create" command to an integer
   */
  override fun getCommandsMap() = mapOf("create" to COMMAND_CREATE, "test" to COMMAND_TEST)

  /**
   * Handle "create" command (called from JS) and call createFragment method
   */
  override fun receiveCommand(
    root: FrameLayout,
    commandId: String,
    args: ReadableArray?
  ) {
    super.receiveCommand(root, commandId, args)
    val reactNativeViewId = requireNotNull(args).getInt(0)

    when (commandId.toInt()) {
      COMMAND_CREATE -> createFragment(root, reactNativeViewId)
      COMMAND_TEST -> Log.d("TEST", "Testing out 'test' command")
    }
  }

  /**
   * Replace your React Native view with a custom fragment
   */
  private fun createFragment(root: FrameLayout, reactNativeViewId: Int) {
    val parentView = root.findViewById<ViewGroup>(reactNativeViewId)
    setupLayout(parentView)

    val myFragment = FaceTecFragment()
    val activity = reactContext.currentActivity as FragmentActivity
    activity.supportFragmentManager
      .beginTransaction()
      .replace(reactNativeViewId, myFragment, reactNativeViewId.toString())
      .commit()
    viewId = myFragment.id
  }

  private fun setupLayout(view: View) {
    Choreographer.getInstance().postFrameCallback(object : Choreographer.FrameCallback {
      override fun doFrame(frameTimeNanos: Long) {
        manuallyLayout(view)
        view.viewTreeObserver.dispatchOnGlobalLayout()
        Choreographer.getInstance().postFrameCallback(this)
      }
    })
  }

  /**
   * Layout all children properly
   */
  private fun manuallyLayout(view: View) {
    // propWidth and propHeight coming from react-native props
    val width = requireNotNull(propWidth)
    val height = requireNotNull(propHeight)

    // https://developer.android.com/reference/android/view/View.MeasureSpec
    view.measure(
      View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
      View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
    )

    view.layout(0, 0, width, height)
  }

  private fun getFontFace(fontName: String, fontWeight: Int?): Typeface {
    val fonts = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      SystemFonts.getAvailableFonts()
    } else {
      TODO("VERSION.SDK_INT < Q")
    }

    var result: Typeface = Typeface.DEFAULT
    if (fonts.isEmpty()) {
      return result
    }

    fonts.iterator().forEach { font ->
      if (font.file.toString().lowercase().contains(fontName.lowercase())) {
        result = Typeface.createFromFile(font.file)
        if (fontWeight != null && fontWeight == font.style.weight) {
          return@forEach
        }
      }
    }

    return result;
  }

  @ReactProp(name = "vocalGuidanceMode")
  fun setVocalGuidanceMode(view: View, mode: String) {
    viewModel?.setVocalGuidanceMode(
      when (mode) {
        "minimal" -> VocalGuidanceMode.MINIMAL
        "full" -> VocalGuidanceMode.FULL
        else -> {
          Log.d("ReactNativeFaceTec", "Chosen mode ($mode) doesn't exist")
          VocalGuidanceMode.OFF
        }
      }
    )
  }

  @ReactProp(name = "sessionToken")
  fun setSessionToken(view: View, token: String) {
    viewModel?.setSessionToken(token)
  }

  @ReactProp(name = "deviceKeyIdentifier")
  fun setDeviceKeyIdentifier(view: View, deviceKeyIdentifier: String) {
    viewModel?.setDeviceKeyIdentifier(deviceKeyIdentifier)
  }

  @ReactProp(name = "productionKeyText")
  fun setProductionKeyText(view: View, productionKeyText: String) {
    viewModel?.setProductionKeyText(productionKeyText)
  }

  @ReactProp(name = "faceScanEncryptionKey")
  fun setFaceScanEncryptionKey(view: View, faceScanEncryptionKey: String) {
    viewModel?.setFaceScanEncryptionKey(faceScanEncryptionKey)
  }

  @ReactPropGroup(names = ["width", "height"], customType = "Style")
  fun setStyle(view: FrameLayout, index: Int, value: Int) {
    if (index == 0) propWidth = value
    if (index == 1) propHeight = value
  }

  @ReactProp(name = "customization")
  fun setCustomization(view: View, customization: ReadableMap) {
    val faceTecCustomization = FaceTecCustomization()
    customization.entryIterator.forEach { entry ->
      val properties = entry.value as ReadableMap
      when (entry.key) {

        // faceTecSessionTimerCustomization -----------------------------------------------

        "faceTecSessionTimerCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "livenessCheckNoInteractionTimeout" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.sessionTimerCustomization.livenessCheckNoInteractionTimeout =
                    value
                }
              }
              "idScanNoInteractionTimeout" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = value
                }
              }
            }
          }
        }

        // faceTecOCRConfirmationCustomization --------------------------------------------

        "faceTecOCRConfirmationCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "backgroundColors" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.ocrConfirmationCustomization.backgroundColors =
                      Color.parseColor(color)
                  }
                }
              }
              "mainHeaderDividerLineColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.mainHeaderDividerLineColor =
                    Color.parseColor(value)
                }
              }
              "mainHeaderDividerLineWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.mainHeaderDividerLineWidth =
                    value
                }
              }
              "mainHeaderFont" -> {
                Log.d("THEME", "value is ${property.value}")
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.mainHeaderFont = value
                }
              }
              "mainHeaderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.mainHeaderTextColor =
                    Color.parseColor(value)
                }
              }
              "sectionHeaderFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.sectionHeaderFont = value
                }
              }
              "sectionHeaderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.sectionHeaderTextColor =
                    Color.parseColor(value)
                }
              }
              "fieldLabelFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.fieldLabelFont = value
                }
              }
              "fieldLabelTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.fieldLabelTextColor =
                    Color.parseColor(value)
                }
              }
              "fieldValueFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.fieldValueFont = value
                }
              }
              "fieldValueTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.fieldValueTextColor =
                    Color.parseColor(value)
                }
              }
              "inputFieldBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.inputFieldBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "inputFieldFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.inputFieldFont = value
                }
              }
              "inputFieldTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.inputFieldTextColor =
                    Color.parseColor(value)
                }
              }
              "inputFieldBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.inputFieldBorderColor =
                    Color.parseColor(value)
                }
              }
              "inputFieldBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.inputFieldBorderWidth = value
                }
              }
              "inputFieldCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.inputFieldCornerRadius = value
                }
              }
              "inputFieldPlaceholderFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.inputFieldPlaceholderFont = value
                }
              }
              "inputFieldPlaceholderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.inputFieldPlaceholderTextColor =
                    Color.parseColor(value)
                }
              }
              "showInputFieldBottomBorderOnly" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.showInputFieldBottomBorderOnly =
                    value
                }
              }
              "buttonFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.ocrConfirmationCustomization.buttonFont = value
                }
              }
              "buttonTextNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonTextNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonBackgroundNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonTextHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonBackgroundHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonTextDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonBackgroundDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonBorderColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonBorderWidth = value
                }
              }
              "buttonCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ocrConfirmationCustomization.buttonCornerRadius = value
                }
              }
            }
          }
        }

        // faceTecIDScanCustomization -----------------------------------------------------

        "faceTecIDScanCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "showSelectionScreenBrandingImage" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.idScanCustomization.showSelectionScreenBrandingImage = value
                }
              }
              "selectionScreenBrandingImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.selectionScreenBrandingImage = value
                }
              }
              "showSelectionScreenDocumentImage" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.idScanCustomization.showSelectionScreenDocumentImage = value
                }
              }
              "selectionScreenDocumentImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.selectionScreenDocumentImage = value
                }
              }
              "captureScreenBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "captureFrameStrokeColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureFrameStrokeColor =
                    Color.parseColor(value)
                }
              }
              "captureFrameStrokeWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureFrameStrokeWidth = value
                }
              }
              "captureFrameCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureFrameCornerRadius = value
                }
              }
              "activeTorchButtonImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.activeTorchButtonImage = value
                }
              }
              "inactiveTorchButtonImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.inactiveTorchButtonImage = value
                }
              }
              "selectionScreenBackgroundColors" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.idScanCustomization.selectionScreenBackgroundColors =
                      Color.parseColor(color)
                  }
                }
              }
              "selectionScreenForegroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.selectionScreenForegroundColor =
                    Color.parseColor(value)
                }
              }
              "reviewScreenBackgroundColors" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.idScanCustomization.reviewScreenBackgroundColors =
                      Color.parseColor(color)
                  }
                }
              }
              "reviewScreenForegroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.reviewScreenForegroundColor =
                    Color.parseColor(value)
                }
              }
              "reviewScreenTextBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "reviewScreenTextBackgroundBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundBorderColor =
                    Color.parseColor(value)
                }
              }
              "reviewScreenTextBackgroundBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundBorderWidth =
                    value
                }
              }
              "reviewScreenTextBackgroundCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.reviewScreenTextBackgroundCornerRadius =
                    value
                }
              }
              "captureScreenForegroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenForegroundColor =
                    Color.parseColor(value)
                }
              }
              "captureScreenTextBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenTextBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "captureScreenTextBackgroundBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenTextBackgroundBorderColor =
                    Color.parseColor(value)
                }
              }
              "captureScreenTextBackgroundBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenTextBackgroundBorderWidth =
                    value
                }
              }
              "captureScreenTextBackgroundCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenTextBackgroundCornerRadius =
                    value
                }
              }
              "captureScreenFocusMessageTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.captureScreenFocusMessageTextColor =
                    Color.parseColor(value)
                }
              }
              "captureScreenFocusMessageFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.captureScreenFocusMessageFont = value
                }
              }
              "headerFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.headerFont = value
                }
              }
              "subtextFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.subtextFont = value
                }
              }
              "buttonFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.buttonFont = value
                }
              }
              "buttonTextNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonTextNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonBackgroundNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonTextHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonBackgroundHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonTextDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonBackgroundDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonBorderColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonBorderWidth = value
                }
              }
              "buttonCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.idScanCustomization.buttonCornerRadius = value
                }
              }
              "customNFCStartingAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customNFCStartingAnimation = value
                }
              }
              "customNFCScanningAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customNFCScanningAnimation = value
                }
              }
              "customNFCCardStartingAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customNFCCardStartingAnimation = value
                }
              }
              "customNFCCardScanningAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customNFCCardScanningAnimation = value
                }
              }
              "customNFCSkipOrErrorAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customNFCSkipOrErrorAnimation = value
                }
              }
              "customStaticNFCStartingAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customStaticNFCStartingAnimation = value
                }
              }
              "customStaticNFCScanningAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customStaticNFCScanningAnimation = value
                }
              }
              "customStaticNFCSkipOrErrorAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.idScanCustomization.customStaticNFCSkipOrErrorAnimation = value
                }
              }
            }
          }
        }

        // faceTecOverlayCustomization ----------------------------------------------------

        "faceTecOverlayCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "backgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.overlayCustomization.backgroundColor =
                    Color.parseColor(value)
                }
              }
              "brandingImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.overlayCustomization.brandingImage = value
                }
              }
              "showBrandingImage" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.overlayCustomization.showBrandingImage = value
                }
              }
            }
          }
        }

        // faceTecResultScreenCustomization -----------------------------------------------

        "faceTecResultScreenCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "animationRelativeScale" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.animationRelativeScale = value
                }
              }
              "foregroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.foregroundColor =
                    Color.parseColor(value)
                }
              }
              "backgroundColors" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.resultScreenCustomization.backgroundColors =
                      Color.parseColor(color)
                  }
                }
              }
              "activityIndicatorColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.activityIndicatorColor =
                    Color.parseColor(value)
                }
              }
              "customActivityIndicatorImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.customActivityIndicatorImage = value
                }
              }
              "customActivityIndicatorRotationInterval" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.customActivityIndicatorRotationInterval =
                    value
                }
              }
              "customActivityIndicatorAnimation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.customActivityIndicatorAnimation = value
                }
              }
              "showUploadProgressBar" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.showUploadProgressBar = value
                }
              }
              "uploadProgressFillColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.uploadProgressFillColor =
                    Color.parseColor(value)
                }
              }
              "uploadProgressTrackColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.uploadProgressTrackColor =
                    Color.parseColor(value)
                }
              }
              "resultAnimationBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.resultAnimationBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "resultAnimationForegroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.resultScreenCustomization.resultAnimationForegroundColor =
                    Color.parseColor(value)
                }
              }
              "resultAnimationSuccessBackgroundImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.resultAnimationSuccessBackgroundImage = value
                }
              }
              "resultAnimationUnsuccessBackgroundImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.resultAnimationUnsuccessBackgroundImage = value
                }
              }
              "customResultAnimationSuccess" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.customResultAnimationSuccess = value
                }
              }
              "customResultAnimationUnsuccess" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.customResultAnimationUnsuccess = value
                }
              }
              "customStaticResultAnimationSuccess" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.customStaticResultAnimationSuccess = value
                }
              }
              "customStaticResultAnimationUnsuccess" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.customStaticResultAnimationUnsuccess = value
                }
              }
              "messageFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.resultScreenCustomization.messageFont = value
                }
              }
            }
          }
        }

        // faceTecGuidanceCustomization ---------------------------------------------------

        "faceTecGuidanceCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "backgroundColors" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.guidanceCustomization.backgroundColors =
                      Color.parseColor(color)
                  }
                }
              }
              "foregroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.foregroundColor =
                    Color.parseColor(value)
                }
              }
              "headerFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.headerFont = value
                }
              }
              "subtextFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.subtextFont = value
                }
              }
              "readyScreenHeaderFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.readyScreenHeaderFont = value
                }
              }
              "readyScreenHeaderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenHeaderTextColor =
                    Color.parseColor(value)
                }
              }
              "readyScreenHeaderAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenHeaderAttributedString =
                    value
                }
              }
              "readyScreenSubtextFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.readyScreenSubtextFont = value
                }
              }
              "readyScreenSubtextTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenSubtextTextColor =
                    Color.parseColor(value)
                }
              }
              "readyScreenSubtextAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenSubtextAttributedString =
                    value
                }
              }
              "retryScreenHeaderFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.retryScreenHeaderFont = value
                }
              }
              "retryScreenHeaderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenHeaderTextColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenHeaderAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenHeaderAttributedString =
                    value
                }
              }
              "retryScreenSubtextFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.retryScreenSubtextFont = value
                }
              }
              "retryScreenSubtextTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenSubtextTextColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenSubtextAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenSubtextAttributedString =
                    value
                }
              }
              "buttonFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.buttonFont = value
                }
              }
              "buttonTextNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonTextNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonBackgroundNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonTextHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonBackgroundHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonTextDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonBackgroundDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonBorderColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonBorderWidth = value
                }
              }
              "buttonCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.buttonCornerRadius = value
                }
              }
              "readyScreenOvalFillColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenOvalFillColor =
                    Color.parseColor(value)
                }
              }
              "readyScreenTextBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenTextBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "readyScreenTextBackgroundCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.readyScreenTextBackgroundCornerRadius =
                    value
                }
              }
              "retryScreenImageBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenImageBorderColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenImageBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenImageBorderWidth = value
                }
              }
              "retryScreenImageCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenImageCornerRadius = value
                }
              }
              "retryScreenOvalStrokeColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenOvalStrokeColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenIdealImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.retryScreenIdealImage = value
                }
              }
              "retryScreenSlideshowImages" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.retryScreenSlideshowImages = value
                }
              }
              "retryScreenSlideshowInterval" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.retryScreenSlideshowInterval = value
                }
              }
              "enableRetryScreenSlideshowShuffle" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.guidanceCustomization.enableRetryScreenSlideshowShuffle =
                    value
                }
              }
              "cameraPermissionsScreenImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.guidanceCustomization.cameraPermissionsScreenImage = value
                }
              }
            }
          }
        }

        // faceTecFrameCustomization ------------------------------------------------------

        "faceTecFrameCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "borderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.frameCustomization.borderWidth = value
                }
              }
              "cornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.frameCustomization.cornerRadius = value
                }
              }
              "borderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.frameCustomization.borderColor = Color.parseColor(value)
                }
              }
              "backgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.frameCustomization.backgroundColor = Color.parseColor(value)
                }
              }
              "elevation" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.frameCustomization.elevation = value
                }
              }
            }
          }
        }

        // faceTecFeedbackCustomization ---------------------------------------------------

        "faceTecFeedbackCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "cornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.feedbackCustomization.cornerRadius = value
                }
              }
              "backgroundColors" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.feedbackCustomization.backgroundColors =
                      Color.parseColor(color)
                  }
                }
              }
              "textColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.feedbackCustomization.textColor = Color.parseColor(value)
                }
              }
              "textFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.feedbackCustomization.textFont = value
                }
              }
              "enablePulsatingText" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.feedbackCustomization.enablePulsatingText = value
                }
              }
              "elevation" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.feedbackCustomization.elevation = value
                }
              }
            }
          }
        }

        // faceTecOvalCustomization -------------------------------------------------------

        "faceTecOvalCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "strokeWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ovalCustomization.strokeWidth = value
                }
              }
              "strokeColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ovalCustomization.strokeColor = Color.parseColor(value)
                }
              }
              "progressStrokeWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ovalCustomization.progressStrokeWidth = value
                }
              }
              "progressColor1" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ovalCustomization.progressColor1 = Color.parseColor(value)
                }
              }
              "progressColor2" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.ovalCustomization.progressColor2 = Color.parseColor(value)
                }
              }
              "progressRadialOffset" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.ovalCustomization.progressRadialOffset = value
                }
              }
            }
          }
        }

        // faceTecCancelButtonCustomization -----------------------------------------------

        "faceTecCancelButtonCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "location" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.cancelButtonCustomization.location = value
                }
              }
              "customImage" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.cancelButtonCustomization.customImage = value
                }
              }
            }
          }
        }

        // faceTecExitAnimationStyle ------------------------------------------------------

        "faceTecExitAnimationStyle" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {

              "animation" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.exitAnimationStyle.animation = value
                }
              }
            }
          }
        }
      }
    }
    viewModel?.setCustomization(faceTecCustomization)
  }


  companion object {
    const val COMMAND_CREATE = 1
    const val COMMAND_TEST = 2
    const val REACT_CLASS = "FaceTecViewManager"
  }
}
