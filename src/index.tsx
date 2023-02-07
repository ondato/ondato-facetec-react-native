import React, { useRef, useEffect, useState } from 'react';
import {
  requireNativeComponent,
  UIManager as UIManagerWithMissingProp,
  UIManagerStatic,
  Platform,
  Dimensions,
  PixelRatio,
  findNodeHandle,
  View,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';
import { defaultCustomization } from './customization';

const HEIGHT = Dimensions.get('window').height;
const WIDTH = Dimensions.get('window').width;
const LINKING_ERROR =
  `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const ComponentName =
  Platform.OS === 'ios' ? 'RNOFaceTecView' : 'FaceTecViewManager';

const UIManager = UIManagerWithMissingProp as UIManagerStatic & {
  FaceTecViewManager: any;
};

const FaceTecViewManager =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<Types.FaceTecProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

const { FaceTecModule } = NativeModules; // Platform.OS === "android" ? NativeModules : {};

const createFragment = (viewId: number | null) =>
  UIManager.dispatchViewManagerCommand(
    viewId,
    // we are calling the 'create' command
    UIManager.FaceTecViewManager.Commands.create.toString(),
    [viewId]
  );

const AndroidFaceTecView = ({
  show = false,
  onStateUpdate,
  vocalGuidanceMode,
  config,
  customization = defaultCustomization,
}: Types.FaceTecViewProps) => {
  const ref = useRef(null);

  useEffect(() => {
    const eventEmitter = new NativeEventEmitter(FaceTecModule);

    const eventListener = eventEmitter.addListener('onUpdate', (event) => {
      const { status, message, load } = event as Types.FaceTecStateRaw;
      if (onStateUpdate && status)
        onStateUpdate({
          status,
          message,
          load: load ? JSON.parse(load) : undefined,
        });
    });

    return () => {
      if (eventListener) {
        eventListener.remove();
      }
    };
  }, []);

  useEffect(() => {
    if (show) {
      const viewId = findNodeHandle(ref.current);
      createFragment(viewId);
    }
  }, [show]);

  if (!show) return null;

  return (
    <FaceTecViewManager
      style={{
        // converts dpi to px, provide desired height
        height: PixelRatio.getPixelSizeForLayoutSize(0),
        // converts dpi to px, provide desired width
        width: PixelRatio.getPixelSizeForLayoutSize(0),
      }}
      vocalGuidanceMode={vocalGuidanceMode}
      customization={customization}
      {...config}
      ref={ref}
    />
  );
};

const IOSFaceTecView = ({
  config,
  onStateUpdate,
  show,
  vocalGuidanceMode,
  customization = defaultCustomization,
}: Types.FaceTecViewProps) => {
  const [showView, setShowView] = useState(false);

  const dimensions = showView ? { height: HEIGHT, width: WIDTH } : {};

  const onUpdate = (event: any) => {
    const { status, message, load } =
      event?.nativeEvent as Types.FaceTecStateRaw;

    if (status === 'Ready') {
      setShowView(true);
    } else if (
      status === 'Cancelled' ||
      status === 'Failed' ||
      status === 'Succeeded'
    ) {
      setShowView(false);
    }

    if (onStateUpdate && status)
      onStateUpdate({
        status,
        message,
        load: load ? JSON.parse(load) : undefined,
      });
  };

  if (!show) return null;

  return (
    <View style={[{ position: 'absolute' }, dimensions]}>
      <FaceTecViewManager
        style={dimensions}
        vocalGuidanceMode={vocalGuidanceMode ?? 'off'}
        onUpdate={onUpdate}
        customization={JSON.stringify(customization)}
        {...config}
      />
    </View>
  );
};

const FaceTecView = Platform.select({
  ios: IOSFaceTecView,
  android: AndroidFaceTecView,
  default: () => null,
});
type FaceTecViewProps = Types.FaceTecViewProps;
type FaceTecConfig = Types.FaceTecConfig;
type FaceTecStatus = Types.FaceTecStatus;
type FaceTecState = Types.FaceTecState;
type FaceTecLoad = Types.FaceTecLoad;

export {
  defaultCustomization,
  FaceTecView,
  FaceTecViewProps,
  FaceTecConfig,
  FaceTecStatus,
  FaceTecState,
  FaceTecLoad,
};
