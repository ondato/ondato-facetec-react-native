declare module Types {
  type ViewStyle = import('react-native').ViewStyle;

  type FaceTecStatus =
    | 'Not ready'
    | 'Ready'
    | 'Succeeded'
    | 'Failed'
    | 'Cancelled'
    | 'Unknown';

  type FaceTecConfig = {
    deviceKeyIdentifier: string;
    productionKeyText?: string;
    faceScanEncryptionKey?: string;
    sessionToken?: string;
  };

  type FaceTecLoad = {
    faceScanBase64?: string;
    sessionId?: string;
    auditImagesBase64?: Array<string>;
    userAgent?: string;
    lowQualityAuditTrailImagesBase64?: Array<string>;
    externalDatabaseRefID?: string;
  };

  type FaceTecStateRaw = {
    status: FaceTecStatus;
    message?: string;
    load?: string;
  };

  type FaceTecState = {
    status: FaceTecStatus;
    message?: string;
    load?: FaceTecLoad;
  };

  type FaceTecMode = 'checkLiveness' | 'enroll';
  //  | 'authenticate'
  //  | 'matchPhotoID';
  type FaceTecVocalGuidanceMode = 'off' | 'minimal' | 'full';

  type FaceTecProps = {
    onUpdate?: (status: FaceTecState) => void;
    vocalGuidanceMode?: FaceTecVocalGuidanceMode;
    style?: ViewStyle;
    customization?: string | FaceTecCustomization;
    ref?: any;
  } & FaceTecConfig;

  type FaceTecViewProps = {
    show?: boolean;
    onStateUpdate?: (status: FaceTecState) => void;
    config: FaceTecConfig;
    mode?: FaceTecMode;
    vocalGuidanceMode?: FaceTecVocalGuidanceMode;
    customization?: Customization;
    style?: ViewStyle;
  };

  type Font = {} | null;
  type Color = string | null;
  type Image = string | null;
  type Animation = {} | null;

  type Customization = {
    faceTecSessionTimerCustomization?: {
      livenessCheckNoInteractionTimeout?: number;
      idScanNoInteractionTimeout?: number;
    };

    faceTecOCRConfirmationCustomization?: {
      backgroundColors?: Array<Color>;
      mainHeaderDividerLineColor?: Color;
      mainHeaderDividerLineWidth?: number;
      mainHeaderFont?: Font;
      mainHeaderTextColor?: Color;
      sectionHeaderFont?: Font;
      sectionHeaderTextColor?: Color;
      fieldLabelFont?: Font;
      fieldLabelTextColor?: Color;
      fieldValueFont?: Font;
      fieldValueTextColor?: Color;
      inputFieldBackgroundColor?: Color;
      inputFieldFont?: Font;
      inputFieldTextColor?: Color;
      inputFieldBorderColor?: Color;
      inputFieldBorderWidth?: number;
      inputFieldCornerRadius?: number;
      inputFieldPlaceholderFont?: Font;
      inputFieldPlaceholderTextColor?: Color;
      showInputFieldBottomBorderOnly?: boolean;
      buttonFont?: Font;
      buttonTextNormalColor?: Color;
      buttonBackgroundNormalColor?: Color;
      buttonTextHighlightColor?: Color;
      buttonBackgroundHighlightColor?: Color;
      buttonTextDisabledColor?: Color;
      buttonBackgroundDisabledColor?: Color;
      buttonBorderColor?: Color;
      buttonBorderWidth?: number;
      buttonCornerRadius?: number;
    };

    faceTecIDScanCustomization?: {
      showSelectionScreenBrandingImage?: boolean;
      selectionScreenBrandingImage?: Image;
      showSelectionScreenDocumentImage?: boolean;
      selectionScreenDocumentImage?: Image;
      captureScreenBackgroundColor?: Color;
      captureFrameStrokeColor?: Color;
      captureFrameStrokeWidth?: number;
      captureFrameCornerRadius?: number;
      activeTorchButtonImage?: Image;
      inactiveTorchButtonImage?: Image;
      selectionScreenBackgroundColors?: Array<Color>;
      selectionScreenForegroundColor?: Color;
      reviewScreenBackgroundColors?: Array<Color>;
      reviewScreenForegroundColor?: Color;
      reviewScreenTextBackgroundColor?: Color;
      reviewScreenTextBackgroundBorderColor?: Color;
      reviewScreenTextBackgroundBorderWidth?: number;
      reviewScreenTextBackgroundCornerRadius?: number;
      captureScreenForegroundColor?: Color;
      captureScreenTextBackgroundColor?: Color;
      captureScreenTextBackgroundBorderColor?: Color;
      captureScreenTextBackgroundBorderWidth?: number;
      captureScreenTextBackgroundCornerRadius?: number;
      captureScreenFocusMessageTextColor?: Color;
      captureScreenFocusMessageFont?: Font;
      headerFont?: Font;
      subtextFont?: Font;
      buttonFont?: Font;
      buttonTextNormalColor?: Color;
      buttonBackgroundNormalColor?: Color;
      buttonTextHighlightColor?: Color;
      buttonBackgroundHighlightColor?: Color;
      buttonTextDisabledColor?: Color;
      buttonBackgroundDisabledColor?: Color;
      buttonBorderColor?: Color;
      buttonBorderWidth?: number;
      buttonCornerRadius?: number;

      customNFCStartingAnimation?: Animation;
      customNFCScanningAnimation?: Animation;
      customNFCCardStartingAnimation?: Animation;
      customNFCCardScanningAnimation?: Animation;
      customNFCSkipOrErrorAnimation?: Animation;
      customStaticNFCStartingAnimation?: Animation;
      customStaticNFCScanningAnimation?: Animation;
      customStaticNFCSkipOrErrorAnimation?: Animation;
    };

    faceTecOverlayCustomization?: {
      backgroundColor?: string;
      brandingImage?: Image;
      showBrandingImage?: boolean;
    };

    faceTecResultScreenCustomization?: {
      animationRelativeScale?: number;
      foregroundColor?: Color;
      backgroundColors?: Array<Color>;
      activityIndicatorColor?: Color;
      customActivityIndicatorImage?: Image;
      customActivityIndicatorRotationInterval?: number;
      customActivityIndicatorAnimation?: Animation;
      showUploadProgressBar?: boolean;
      uploadProgressFillColor?: Color;
      uploadProgressTrackColor?: Color;
      resultAnimationBackgroundColor?: Color;
      resultAnimationForegroundColor?: Color;
      resultAnimationSuccessBackgroundImage?: Image;
      resultAnimationUnsuccessBackgroundImage?: Image;
      customResultAnimationSuccess?: Animation;
      customResultAnimationUnsuccess?: Animation;
      customStaticResultAnimationSuccess?: Animation;
      customStaticResultAnimationUnsuccess?: Animation;
      messageFont?: Font;
    };

    faceTecGuidanceCustomization?: {
      backgroundColors?: Array<Color>;
      foregroundColor?: Color;
      headerFont?: Font;
      subtextFont?: Font;
      readyScreenHeaderFont?: Font;
      readyScreenHeaderTextColor?: Color;
      readyScreenHeaderAttributedString?: string;
      readyScreenSubtextFont?: Font;
      readyScreenSubtextTextColor?: Color;
      readyScreenSubtextAttributedString?: string;
      retryScreenHeaderFont?: Font;
      retryScreenHeaderTextColor?: Color;
      retryScreenHeaderAttributedString?: string;
      retryScreenSubtextFont?: Font;
      retryScreenSubtextTextColor?: Color;
      retryScreenSubtextAttributedString?: string;
      buttonFont?: Font;
      buttonTextNormalColor?: Color;
      buttonBackgroundNormalColor?: Color;
      buttonTextHighlightColor?: Color;
      buttonBackgroundHighlightColor?: Color;
      buttonTextDisabledColor?: Color;
      buttonBackgroundDisabledColor?: Color;
      buttonBorderColor?: Color;
      buttonBorderWidth?: number;
      buttonCornerRadius?: number;
      readyScreenOvalFillColor?: Color;
      readyScreenTextBackgroundColor?: Color;
      readyScreenTextBackgroundCornerRadius?: number;
      retryScreenImageBorderColor?: Color;
      retryScreenImageBorderWidth?: number;
      retryScreenImageCornerRadius?: number;
      retryScreenOvalStrokeColor?: Color;
      retryScreenIdealImage?: Image;
      retryScreenSlideshowImages?: Array<Image>;
      retryScreenSlideshowInterval?: number;
      enableRetryScreenSlideshowShuffle?: boolean;
      cameraPermissionsScreenImage?: Image;
    };

    faceTecFrameCustomization?: {
      borderWidth?: number;
      cornerRadius?: number;
      borderColor?: string;
      backgroundColor?: string;
      elevation?: number;
    };

    faceTecFeedbackCustomization?: {
      cornerRadius?: number;
      backgroundColors?: Array<Color>;
      textColor?: Color;
      textFont?: Font;
      enablePulsatingText?: boolean;
      elevation?: number;
    };

    faceTecOvalCustomization?: {
      strokeWidth?: number;
      strokeColor?: Color;
      progressStrokeWidth?: number;
      progressColor1?: Color;
      progressColor2?: Color;
      progressRadialOffset?: number;
    };

    faceTecCancelButtonCustomization?: {
      location: 'topLeft' | 'topRight' | 'disabled';
      customImage?: Image;
    };

    faceTecExitAnimationStyle?: {
      animation: 'circleFade' | 'rippleOut' | 'rippleIn' | 'none';
    };
  };
}
