# react-native-photo-picker

React Native wrapper for [PHPickerViewController](https://developer.apple.com/documentation/photokit/phpickerviewcontroller)

## Usage

```javascript
import { pickPhoto } from 'react-native-photo-picker';

pickPhoto((err, photoURL) => {
    // photoURL contains the URL to the selected photo, or null if
    // the user canceled
})
```

