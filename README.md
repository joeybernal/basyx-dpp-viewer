# Digital Passport Viewer

A standalone web page that replicates the Digital Passport module from basyx-aas-web-ui. This viewer displays AAS (Asset Administration Shell) data from a basyx server in a clean, user-friendly interface.

## Features

- **Standalone HTML Page**: No build process required, just open in a browser
- **Identical Look & Feel**: Matches the original Digital Passport module design
- **URL-Based Configuration**: Load any AAS by providing URL parameters
- **Responsive Design**: Works on both desktop and mobile devices
- **Five Main Sections**:
  - General Information
  - Product Carbon Footprint
  - Material Composition
  - Sustainability
  - Compliance

## Usage

### Basic Usage

Open the `index.html` file in your browser with the AAS ID parameter:

```
index.html?id=<your-aas-id>
```

### Working Example (Battery Digital Passport)

```
index.html?id=aHR0cHM2Ly9leGFtcGxlLmNvbS9hYXMvZGlnaXRhbHBhc3Nwb3J0L2JhdHRlcnkwMDE
```

This URL loads a real battery digital passport from the configured Deloitte demo server.

### AAS ID Encoding

The `id` parameter must be **base64url-encoded**:

```javascript
// Example: Encode an AAS ID for URL use
const originalId = "https://example.com/aas/digitalpassport/battery001";
const encodedId = btoa(originalId).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
// Result: aHR0cHM2Ly9leGFtcGxlLmNvbS9hYXMvZGlnaXRhbHBhc3Nwb3J0L2JhdHRlcnkwMDE
```

### URL Parameters

- **`id`** (required): The ID of the AAS to display

### Server Configuration

The viewer is pre-configured to connect to:
- **Server**: `https://aasenv.deloitte.iotdemozone.de`
- **Endpoints**: 
  - `GET /shells/{id}` - Fetch AAS shell data
  - `GET /submodels/{submodelId}` - Fetch submodel data

To change the server URL, modify the `serverUrl` constant in the code.

## Technical Details

### Dependencies

- **Vue.js 3.5.22**: JavaScript framework
- **Vuetify 3.10.5**: Material Design component library
- **Material Design Icons 7.4.47**: Icon library

All dependencies are loaded via CDN, no local installation required.

### Browser Compatibility

- Modern browsers with ES6+ support
- Chrome 61+, Firefox 60+, Safari 11+, Edge 79+

### Theme

The application uses the same color scheme as basyx-aas-web-ui:
- Primary Light: `#0cb2f0`
- Primary Dark: `#f69222`

## Development

### File Structure

```
basyx-dpp-viewer/
├── index.html          # Main application file
└── README.md          # This file
```

### Customization

The page can be customized by modifying the `index.html` file:

1. **Colors**: Update the Vuetify theme configuration
2. **Sections**: Modify the `sections` array to add/remove sections
3. **Components**: Update individual section components for different data display
4. **Styling**: Add custom CSS in the `<style>` section

### Data Structure

The application expects AAS data in the standard basyx format:

```json
{
  "id": "urn:example:aas:1234",
  "idShort": "ExampleAAS",
  "submodels": [
    {
      "keys": [
        {
          "value": "urn:example:submodel:general"
        }
      ]
    }
  ]
}
```

Submodels should contain `submodelElements` arrays with elements having `idShort` and `value` properties.

## CORS Considerations

If accessing basyx servers from a different domain, ensure the server has proper CORS headers configured:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

## Debugging Features

The application includes comprehensive debugging to help troubleshoot issues:

### Debug Panel
- **Automatic Display**: Shows when errors occur or parameters are missing
- **URL Parameters**: Displays the parsed id and serverUrl
- **AAS ID Decoding**: Shows the decoded AAS identifier
- **Request URLs**: Lists all attempted API calls
- **Response Status**: Shows HTTP status codes and error messages
- **CORS Testing**: Checks for cross-origin request issues
- **Timeline**: Chronological log of all operations

### Accessing Debug Info
1. The debug panel appears automatically when issues occur
2. Click "Show Debug Info" button when no AAS data is available
3. Use "Copy Debug Info" to share troubleshooting information

### Common Issues and Solutions

**CORS Errors**: If you see CORS-related errors, the basyx server needs proper headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, OPTIONS
```

**404 Errors**: Check that:
1. The AAS ID is correctly base64url-encoded
2. The AAS actually exists on the server
3. The server URL is correct

**Network Errors**: Verify:
1. The basyx server is accessible
2. Your internet connection is working
3. No firewall is blocking the requests

## Error Handling

The application includes error handling for:
- Missing URL parameters
- Failed AAS fetching
- Failed submodel fetching
- Network connectivity issues
- CORS configuration problems

Error messages are displayed in user-friendly alert boxes with detailed debugging information.

## License

This project follows the same license as basyx-aas-web-ui (MIT License).