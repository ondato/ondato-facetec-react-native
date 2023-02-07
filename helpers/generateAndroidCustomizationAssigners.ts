import { defaultCustomization } from './customization';

type CustomizationProperty = keyof typeof defaultCustomization;

const mapping = {
  faceTecSessionTimerCustomization: 'sessionTimerCustomization',
  faceTecOCRConfirmationCustomization: 'ocrConfirmationCustomization',
  faceTecIDScanCustomization: 'idScanCustomization',
  faceTecOverlayCustomization: 'overlayCustomization',
  faceTecResultScreenCustomization: 'resultScreenCustomization',
  faceTecGuidanceCustomization: 'guidanceCustomization',
  faceTecFrameCustomization: 'frameCustomization',
  faceTecFeedbackCustomization: 'feedbackCustomization',
  faceTecOvalCustomization: 'ovalCustomization',
  faceTecCancelButtonCustomization: 'cancelButtonCustomization',
  faceTecExitAnimationStyle: 'exitAnimationStyle',
};
console.log(`
  @ReactProp(name = "customization")
  fun setCustomization(view: View, customization: ReadableMap) {
    val faceTecCustomization = FaceTecCustomization()
    customization.entryIterator.forEach { entry ->
      val properties = entry.value as ReadableMap
      when (entry.key) {`);

for (const customizationProperty in defaultCustomization) {
  let cProperty = customizationProperty as CustomizationProperty;
  console.log(`
  // ${(cProperty + ' ').padEnd(80, '-')} 
  `);

  console.log(`"${cProperty}" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
    `);

  for (const property in defaultCustomization[cProperty]) {
    if (
      property.toLowerCase().includes('color') &&
      !property.toLowerCase().includes('colors')
    ) {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.${mapping[cProperty]}.${property} = Color.parseColor(value)
                }
              }`);
    } else if (
      property.toLowerCase().includes('width') ||
      property.toLowerCase().includes('radius') ||
      property.toLowerCase().includes('timeout') ||
      property.toLowerCase().includes('elevation') ||
      property.toLowerCase().includes('interval') ||
      property.toLowerCase().includes('offset')
    ) {
      console.log(`"${property}" -> {
                val value = property.value as? Int;
                if (value != null) {
                  faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (property.toLowerCase().includes('attributedstring')) {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (property.toLowerCase().includes('colors')) {
      console.log(`"${property}" -> {
                val value = property.value as? ReadableArray;
                if (value != null) {
                  val color = value.getString(0);
                  if (color is String) {
                    faceTecCustomization.${mapping[cProperty]}.${property} = Color.parseColor(color)
                  }
                }
              }`);
    } else if (property.toLowerCase().includes('font')) {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (
      (property.toLowerCase().includes('show') &&
        !property.toLowerCase().includes('slideshow')) ||
      property.toLowerCase().includes('enable')
    ) {
      console.log(`"${property}" -> {
                val value = property.value as? Boolean
                if (value != null) {
                  faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (
      property.toLowerCase().includes('images') &&
      !property.toLowerCase().includes('slideshow')
    ) {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (
      property.toLowerCase().includes('image') &&
      !property.toLowerCase().includes('slideshow')
    ) {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (property.toLowerCase().includes('animation')) {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else if (property.toLowerCase() === 'location') {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  //faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    } else {
      console.log(`"${property}" -> {
                val value = property.value as? String;
                if (value != null) {
                  faceTecCustomization.${mapping[cProperty]}.${property} = value
                }
              }`);
    }
  }

  console.log('}}}');
}
console.log(`}}
  viewModel?.setCustomization(faceTecCustomization)
}`);
