# react-native-facetec

React Native Facetec integration

## Installation

1. Clone this repository
2. Add this repository as a dependency, currently it's not published to npm,
   so you need to add it as a dependency from a local path

```json
"dependencies": {
  "react-native-facetec": "file:/path/to/react-native-facetec"
}
```

3. Install the dependencies

```bash
yarn install
```

## Usage

```js
import { FacetecConfig, initialize } from 'react-native-facetec';

// ...
const config: FacetecConfig = {
  key: '',
  deviceKeyIdentifier: '',
  token: '',
  publicFaceScanEncryptionKey: '',
};

const App: FC = () => {
  useEffect(() => {
    initialize(config).then(console.log);
  }, []);
};
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

```

```
