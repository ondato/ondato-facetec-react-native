import React, { useEffect, useState } from 'react';
import {
  StyleSheet,
  View,
  ScrollView,
  Pressable,
  Text,
  Platform,
  Switch,
} from 'react-native';
import {
  FaceTecConfig,
  FaceTecView,
  FaceTecState,
  FaceTecLoad,
} from 'react-native-facetec';

const CLIENT_ID = 'idv.demo.api@ondato.com';
const CLIENT_SECRET =
  '8cbe1edf94ff042dd5cd34f0fd9d28139dbb5934e755abdd19c75204d2f263a0';
const SETUP_ID = '8ed2da35-3f71-494b-acae-7b10f76c798f';
const IDV_API_URL = 'https://app-idvapi-snd-ond.azurewebsites.net';
const OAUTH2_URL = 'https://sandbox-id.ondato.com/connect/token';
const IDV_SESSIONS_API_URL = 'https://app-idvsapi-snd-ond.azurewebsites.net';

type OAuth2Data = {
  access_token: string;
  expires_in: number;
  token_type: string;
  scope: string;
};

const getOauth2Data = async (): Promise<OAuth2Data | null> => {
  console.log('Getting OAuth2 data...');
  try {
    const response = await fetch(OAUTH2_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        search_params: 'idv_api',
      }).toString(),
    });
    if (response.status === 200) {
      const data = (await response.json()) as OAuth2Data;
      console.log(`Oauth2 data -> ${JSON.stringify(data, null, 2)}`);
      return data;
    }
  } catch (error) {
    console.error(`Oauth2 error: ${error}`);
  }
  return null;
};

const getIdentityVerificationId = async (
  token: string
): Promise<string | null> => {
  console.log('Getting identity verification id...');
  try {
    const response = await fetch(`${IDV_API_URL}/v1/identity-verifications`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        registration: {
          email: 'John@email.com',
          firstName: 'John',
          middleName: 'Adam',
          lastName: 'Johnson',
          personalCode: '1214148111000',
          phoneNumber: 370624515141,
          dateOfBirth: '1985-01-14',
        },
        externalReferenceId: '123',
        setupId: SETUP_ID,
      }),
    });

    if (response.status === 201) {
      const data = await response.json();
      console.log(
        `Identity verification data: ${JSON.stringify(data, null, 2)}`
      );
      if (data?.id) {
        return data.id;
      }
    }
  } catch (error) {
    console.error(`Identity verification error: ${error}`);
  }
  return null;
};

type SetupIdResponse = {
  id: string;
  applicationId: string;
  resourceDirectoryName: string;
  generalAppSetting: any;
  webAppSetting: {
    baseUrl: string;
    localisationSettings: [
      {
        language: string;
        successRedirectUrl: string;
        failureRedirectUrl: string;
        pageTitle: string;
      }
    ];
    defaultLocalisationSetting: {
      language: string;
      successRedirectUrl: string;
      consentDeclinedRedirectUrl: string;
      failureRedirectUrl: string;
      pageTitle: string;
    };
  };
  omnichannel: {
    enabled: boolean;
    appStoreEnabled: boolean;
    onlyMobileEnabled: boolean;
  };
  submissionContinuity: {
    enabled: boolean;
  };
  sessionScreenRecording: {
    enabled: boolean;
  };
  steps: [
    {
      type: string;
      order: number;
      setupId: string;
    }
  ];
};

const getSetupId = async (
  identityVerificationId: string,
  fullAccessSessionToken: string
): Promise<string | null> => {
  console.log('Getting setup id...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/identity-verifications/${identityVerificationId}/setup`,
      {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${fullAccessSessionToken}`,
        },
      }
    );

    if (response.status === 200) {
      const data = (await response.json()) as SetupIdResponse;
      console.log(`Setup id data: ${JSON.stringify(data, null, 2)}`);
      if (data?.steps.length > 0 && data.steps[0].setupId) {
        return data.steps[0].setupId;
      }
    }
  } catch (error) {
    console.error(`Setup id error: ${error}`);
  }
  return null;
};

type TokenData = {
  accessToken: string;
  tokenType: string;
};

const getSessionTokenData = async (
  identityVerificationId: string
): Promise<TokenData | null> => {
  console.log('Getting session token data...');
  try {
    const response = await fetch(`${IDV_SESSIONS_API_URL}/v1/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        identityVerificationId: identityVerificationId,
      }),
    });

    if (response.status === 200) {
      const data = await response.json();
      console.log(`Session token data: ${JSON.stringify(data, null, 2)}`);
      return data;
    }
  } catch (error) {
    console.error(`Session token error: ${error}`);
  }
  return null;
};

const getFullAccessSessionTokenData = async (
  identityVerificationId: string,
  sessionToken: string
): Promise<TokenData | null> => {
  console.log('Getting full access session token data...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/sessions/${identityVerificationId}/full-access-token`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${sessionToken}`,
        },
        body: JSON.stringify({}),
      }
    );

    if (response.status === 200) {
      const data = await response.json();
      console.log(
        `Full access session token data: ${JSON.stringify(data, null, 2)}`
      );
      return data;
    }
  } catch (error) {
    console.error(`Full access session token error: ${error}`);
  }
  return null;
};

type FaceTecMobileLicense = {
  appId: string;
  expiryDate: string;
  deviceKeyIdentifier: string;
  publicFaceScanEncryptionKey: string;
  key: string;
};

const getFaceTecMobileLicense = async (
  fullAccessSessionToken: string
): Promise<FaceTecMobileLicense | null> => {
  console.log('Getting FaceTec mobile license...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/face-tec/mobile-license`,
      {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${fullAccessSessionToken}`,
        },
      }
    );

    if (response.status === 200) {
      const data = await response.json();
      console.log(
        `FaceTec mobile license data: ${JSON.stringify(data, null, 2)}`
      );
      return data;
    }
  } catch (error) {
    console.error(`FaceTec mobile license error: ${error}`);
  }
  return null;
};

type FaceTecSessionTokenData = {
  sessionToken: string;
};

const getFaceTecSessionToken = async (
  fullAccessSessionToken: string
): Promise<string | null> => {
  console.log('Getting FaceTec session token...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/face-tec/sessions`,
      {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${fullAccessSessionToken}`,
        },
      }
    );

    if (response.status === 200) {
      const data = (await response.json()) as FaceTecSessionTokenData;
      console.log(
        `FaceTec session token data: ${JSON.stringify(data, null, 2)}`
      );
      if (data?.sessionToken) {
        return data.sessionToken;
      }
    }
  } catch (error) {
    console.error(`FaceTec session token error: ${error}`);
  }
  return null;
};

const getKycId = async (
  setupId: string,
  identityVerificationId: string,
  fullAccessSessionToken: string
): Promise<string | null> => {
  console.log('Getting KYC id token...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/kyc-identifications`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${fullAccessSessionToken}`,
        },
        body: JSON.stringify({
          setupId,
          identityVerificationId,
        }),
      }
    );

    if (response.status === 201) {
      const data = await response.json();
      console.log(`KYC id data: ${JSON.stringify(data, null, 2)}`);
      if (data?.id) {
        return data.id;
      }
    }
  } catch (error) {
    console.error(`KYC id error: ${error}`);
  }
  return null;
};

const putLivenessCheckResults = async (
  kycId: string,
  fullAccessSessionToken: string,
  auditImagesBase64: Array<string>
): Promise<string> => {
  console.log('Putting liveness check results...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/kyc-identifications/${kycId}/face-tec-liveness-2d`,
      {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${fullAccessSessionToken}`,
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: JSON.stringify({
          auditImagesBase64,
        }),
      }
    );

    console.log(JSON.stringify(response, null, 2));

    return response.status.toString();
  } catch (error) {
    console.error(`Put liveness check results error: ${error}`);
  }
  return 'Something went wrong';
};

type EnrollmentParams = {
  kycId: string;
  sessionId: string;
  faceScanBase64: string;
  auditImagesBase64: Array<string>;
  lowQualityAuditImagesBase64: Array<string>;
  sessionUserAgent: string;
  fullAccessSessionToken: string;
};

const putEnrollmentResults = async ({
  kycId,
  sessionId,
  faceScanBase64,
  auditImagesBase64,
  lowQualityAuditImagesBase64,
  sessionUserAgent,
  fullAccessSessionToken,
}: EnrollmentParams): Promise<string> => {
  console.log('Putting enrollment results...');
  try {
    const response = await fetch(
      `${IDV_SESSIONS_API_URL}/v1/kyc-identifications/${kycId}/face-tec-enrollment-3d`,
      {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${fullAccessSessionToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          sessionId,
          faceScanBase64,
          auditImagesBase64,
          lowQualityAuditImagesBase64,
          sessionUserAgent,
        }),
      }
    );

    console.log(JSON.stringify(response, null, 2));

    return response.status.toString();
  } catch (error) {
    console.error(`Put enrollment results error: ${error}`);
  }
  return 'Something went wrong';
};

// This is our INPUT
const getFaceTecConfiguration = async (
  fullAccessSessionToken: string
): Promise<FaceTecConfig | null> => {
  console.log('Getting FaceTec demo configuration...');
  const baseConfiguration: FaceTecConfig = {
    deviceKeyIdentifier: '',
  };

  const {
    expiryDate,
    appId,
    deviceKeyIdentifier,
    key,
    publicFaceScanEncryptionKey,
  } = (await getFaceTecMobileLicense(fullAccessSessionToken)) ?? {};

  if (deviceKeyIdentifier) {
    baseConfiguration.deviceKeyIdentifier = deviceKeyIdentifier;
  }

  if (publicFaceScanEncryptionKey) {
    baseConfiguration.faceScanEncryptionKey = publicFaceScanEncryptionKey;
  }

  if (expiryDate && appId && key) {
    const productionKeyText = `appId = ${appId}\nexpiryDate = ${expiryDate}\nkey = ${key}`;

    baseConfiguration.productionKeyText = productionKeyText;
  }

  const faceTecSessionToken = await getFaceTecSessionToken(
    fullAccessSessionToken
  );
  if (faceTecSessionToken) {
    baseConfiguration.sessionToken = faceTecSessionToken;
  }

  if (baseConfiguration.deviceKeyIdentifier) {
    return baseConfiguration;
  }

  return null;
};

export default function App() {
  const [show, setShow] = useState(false);
  const [configuration, setConfiguration] = useState<FaceTecConfig>();
  const [state, setState] = useState<FaceTecState>();
  const [response2d, setResponse2d] = useState<string>();
  const [response3d, setResponse3d] = useState<string>();
  const [is3dEnabled, setIs3dEnabled] = useState<boolean>(false);

  const [identityVerificationId, setIdentityVerificationId] =
    useState<string>();
  const [fullAccessSessionToken, setFullAccessSessionToken] =
    useState<string>();
  const [setupId, setSetupId] = useState<string>();
  const [kycId, setKycId] = useState<string>();

  const isButtonDisabled = show || !fullAccessSessionToken;

  useEffect(() => {
    const { status, load } = state || {};

    const putData = async (load: FaceTecLoad) => {
      if (
        kycId &&
        load?.auditImagesBase64 &&
        load?.faceScanBase64 &&
        load?.sessionId &&
        typeof load?.userAgent === 'string' &&
        load?.lowQualityAuditTrailImagesBase64 &&
        fullAccessSessionToken
      ) {
        if (is3dEnabled) {
          const enrollmentResponse = await putEnrollmentResults({
            kycId,
            sessionId: load.sessionId,
            faceScanBase64: load.faceScanBase64,
            auditImagesBase64: load.auditImagesBase64,
            lowQualityAuditImagesBase64: load.lowQualityAuditTrailImagesBase64,
            sessionUserAgent: load.userAgent,
            fullAccessSessionToken,
          });

          setResponse3d(enrollmentResponse);
        } else {
          const livenessResponse = await putLivenessCheckResults(
            kycId,
            fullAccessSessionToken,
            load.auditImagesBase64
          );

          setResponse2d(livenessResponse);
        }
      }
    };

    if (status) {
      switch (status) {
        case 'Succeeded':
          // do something
          console.log('Succeeded');
          //console.log(Object.keys(load));
          if (load) {
            /*Object.keys(load).forEach((k) => {
              const key = k as keyof typeof load;
              const value = load[key] ?? '';
              console.log('{');
              if (typeof value === 'string') {
                console.log(`${k}: "${value.slice(0, 400)}"`);
              } else if (typeof value === 'object' && value.length > 0) {
                console.log(
                  `${k}: [${value.map(
                    (item) => `"${item.slice(0, 100)}...",\n`
                  )} items`
                );
              }
              console.log('}');
            });*/
            console.log(JSON.stringify(load, null, 2));
            putData(load);
          }
          setShow(false);
          break;
        case 'Failed':
          // do something
          console.log('Failed');
          setShow(false);
          break;
        case 'Cancelled':
          // do something
          console.log('Cancelled');
          setShow(false);
          break;
        default:
          console.log(JSON.stringify(state, null, 2));
          // do something
          break;
      }
    }
  }, [state]);

  useEffect(() => {
    const getCredentials = async () => {
      const { access_token: accessToken } = (await getOauth2Data()) ?? {};

      if (accessToken) {
        const identityVerificationId = await getIdentityVerificationId(
          accessToken
        );

        if (identityVerificationId) {
          const { accessToken: sessionToken } =
            (await getSessionTokenData(identityVerificationId)) ?? {};

          if (sessionToken) {
            const { accessToken: fullAccessSessionToken } =
              (await getFullAccessSessionTokenData(
                identityVerificationId,
                sessionToken
              )) ?? {};

            if (fullAccessSessionToken) {
              const setupId =
                (await getSetupId(
                  identityVerificationId,
                  fullAccessSessionToken
                )) ?? '';

              const kycId = await getKycId(
                setupId,
                identityVerificationId,
                fullAccessSessionToken
              );

              // All or nothing, strange server logic, but it's beyond my control
              // and we need all of these values to continue
              if (setupId && kycId) {
                setIdentityVerificationId(identityVerificationId);
                setFullAccessSessionToken(fullAccessSessionToken);
                setSetupId(setupId);
                setKycId(kycId);
              }
            }
          }
        }
      }
    };

    getCredentials();
  }, []);

  console.log(configuration);

  return (
    <ScrollView contentContainerStyle={styles.scrollViewContainer}>
      <View style={styles.credentials}>
        <View style={styles.credential}>
          <Text style={styles.title}>{`Identity verification id: `}</Text>
          <Text style={styles.value}>{identityVerificationId}</Text>
        </View>
        <View style={styles.credential}>
          <Text style={styles.title}>{`Full access session token: `}</Text>
          <Text style={styles.value} numberOfLines={3} ellipsizeMode="tail">
            {fullAccessSessionToken}
          </Text>
        </View>
        <View style={styles.credential}>
          <Text style={styles.title}>{`Setup id: `}</Text>
          <Text style={styles.value}>{setupId}</Text>
        </View>
      </View>
      <Pressable
        style={[styles.button, isButtonDisabled && styles.disabledButton]}
        onPress={async () => {
          if (fullAccessSessionToken && setupId && identityVerificationId) {
            const configuration = await getFaceTecConfiguration(
              fullAccessSessionToken
            );
            if (configuration) {
              setConfiguration(configuration);
              setShow(true);
            } else {
              console.log("Couldn't get configuration");
            }
          }
        }}
        disabled={isButtonDisabled}
      >
        <Text style={styles.buttonText}>Start</Text>
      </Pressable>
      <View style={styles.modeSelectionContainer}>
        <View
          style={[
            styles.modeTextContainer,
            !is3dEnabled && styles.modeSelectedTextContainer,
          ]}
        >
          <Text
            style={[styles.modeText, !is3dEnabled && styles.modeSelectedText]}
          >
            2D Mode
          </Text>
        </View>
        <Switch
          trackColor={{ false: '#767577', true: '#767577' }}
          ios_backgroundColor="#767577"
          onValueChange={() => setIs3dEnabled(!is3dEnabled)}
          value={is3dEnabled}
          style={styles.modeSwitch}
        />
        <View
          style={[
            styles.modeTextContainer,
            is3dEnabled && styles.modeSelectedTextContainer,
          ]}
        >
          <Text
            style={[styles.modeText, is3dEnabled && styles.modeSelectedText]}
          >
            3D Mode
          </Text>
        </View>
      </View>
      {response2d && (
        <View style={styles.response}>
          <Text style={styles.title}>
            {'/v1/kyc-identifications/{id}/face-tec-liveness-2d'}
          </Text>
          <Text style={styles.value}>
            {JSON.stringify(response2d, null, 2)}
          </Text>
        </View>
      )}
      {response3d && (
        <View style={styles.response}>
          <Text style={styles.title}>
            {'/v1/kyc-identifications/{id}/face-tec-enrollment-3d'}
          </Text>
          <Text style={styles.value}>
            {JSON.stringify(response3d, null, 2)}
          </Text>
        </View>
      )}

      {configuration && (
        <FaceTecView
          config={configuration}
          onStateUpdate={setState}
          mode="enroll"
          show={show}
        />
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scrollViewContainer: {
    flexGrow: 1,
    padding: 32,
    backgroundColor: 'white',
  },

  credentials: {
    marginBottom: 20,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    width: '100%',
  },
  credential: {
    marginBottom: 10,
  },
  title: {
    fontWeight: 'bold',
    color: 'black',
  },
  value: {
    color: 'gray',
    fontFamily: Platform.OS === 'android' ? 'monospace' : 'Menlo',
  },

  button: {
    justifyContent: 'center',
    alignContent: 'center',
    marginVertical: 20,
    backgroundColor: '#fd5a28',
    height: 60,
    borderRadius: 30,
  },
  disabledButton: {
    opacity: 0.3,
  },
  buttonText: {
    fontSize: 24,
    fontWeight: '400',
    color: '#FFF',
    textAlign: 'center',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },

  modeSelectionContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  modeSwitch: {
    marginHorizontal: 16,
  },
  modeTextContainer: {
    height: 31,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  modeSelectedTextContainer: {
    backgroundColor: '#fd5a28',
  },
  modeText: {},
  modeSelectedText: {
    color: '#fff',
  },

  response: {},
});
