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

for (const customizationProperty in defaultCustomization) {
  let cProperty = customizationProperty as CustomizationProperty;
  //console.log(`${customizationProperty} -> ${defaultCustomization[cProperty]}`);
  // remove faceTec prefix
  //const nativeCustomizationProperty =
  //  cProperty.substring(7, 8).toLowerCase() + cProperty.substring(8);
  //console.log(`${cProperty}: "${nativeCustomizationProperty}",`);

  console.log(`
  // ${(cProperty + ' ').padEnd(80, '-')} 
  `);

  for (const property in defaultCustomization[cProperty]) {
    if (
      property.toLowerCase().includes('color') &&
      !property.toLowerCase().includes('colors')
    ) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  faceTecCustomization.${mapping[cProperty]}.${property} = UIColor(hex: unwrapped);
}`);
    } else if (
      cProperty === 'faceTecFeedbackCustomization' &&
      property === 'backgroundColors'
    ) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
      let feedbackBackgroundColorLayer = CAGradientLayer()
      let colors = unwrapped.map { UIColor(hex: $0).cgColor };
      feedbackBackgroundColorLayer.colors = colors
      feedbackBackgroundColorLayer.locations = [0,1]
      feedbackBackgroundColorLayer.startPoint = CGPoint.init(x: 0, y: 0)
      feedbackBackgroundColorLayer.endPoint = CGPoint.init(x: 1, y: 0)
      faceTecCustomization.${mapping[cProperty]}.backgroundColor = feedbackBackgroundColorLayer;
}`);
    } else if (
      property.toLowerCase().includes('width') ||
      property.toLowerCase().includes('radius')
    ) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  faceTecCustomization.${mapping[cProperty]}.${property} = unwrapped;
}`);
    } else if (property.toLowerCase().includes('attributedstring')) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  //faceTecCustomization.${mapping[cProperty]}.${property} = NSAttributedString(string: unwrapped);
}`);
    } else if (property.toLowerCase().includes('colors')) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  faceTecCustomization.${mapping[cProperty]}.${property} = unwrapped.map { UIColor(hex: $0) };
}`);
    } else if (property.toLowerCase().includes('font')) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  //faceTecCustomization.${mapping[cProperty]}.${property} = unwrapped;
}`);
    } else if (
      (property.toLowerCase().includes('images') &&
        !property.toLowerCase().includes('show')) ||
      property.toLowerCase().includes('slideshow')
    ) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  //faceTecCustomization.${mapping[cProperty]}.${property} = unwrapped;
}`);
    } else if (
      (property.toLowerCase().includes('image') &&
        !property.toLowerCase().includes('show')) ||
      property.toLowerCase().includes('slideshow')
    ) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  faceTecCustomization.${mapping[cProperty]}.${property} = UIImage(named: unwrapped)
}`);
    } else if (property.toLowerCase().includes('animation')) {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  //faceTecCustomization.${mapping[cProperty]}.${property} = unwrapped;
}`);
    } else if (property.toLowerCase() === 'elevation') {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  //faceTecCustomization.${mapping[cProperty]}.shadow = unwrapped;
}`);
    } else {
      console.log(`if let unwrapped = customization.${customizationProperty}?.${property} {
  faceTecCustomization.${mapping[cProperty]}.${property} = unwrapped;
}`);
    }
  }
}
