# YouTube API Setup Guide

This guide will help you set up the YouTube Data API v3 for the YouTube Reels feature in your Flutter app.

## Step 1: Get YouTube API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the YouTube Data API v3:
   - Go to "APIs & Services" > "Library"
   - Search for "YouTube Data API v3"
   - Click on it and press "Enable"
4. Create credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key

## Step 2: Configure the API Key

1. Open `Frontend/lib/config.dart`
2. Replace `YOUR_YOUTUBE_API_KEY_HERE` with your actual API key:

```dart
class Config {
  // YouTube API Configuration
  static const String youtubeApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
  
  // ... rest of the configuration
}
```

## Step 3: API Quotas and Limits

- **Daily Quota**: 10,000 units per day (free tier)
- **Search Request**: 100 units per request
- **Video Details Request**: 1 unit per request
- **Estimated Usage**: ~100-200 units per search (depending on results)

## Step 4: Test the Integration

1. Run your Flutter app
2. Search for a product in the search bar
3. Tap on the "Reels" button in the bottom navigation
4. The app should load YouTube Shorts related to your search query

## Features

- **YouTube Shorts Search**: Finds short videos related to your product search
- **Video Details**: Shows duration, view count, like count
- **Direct Links**: Tap to watch videos on YouTube
- **Error Handling**: Graceful fallbacks for failed requests
- **Loading States**: Visual feedback during API calls

## Troubleshooting

### Common Issues:

1. **"API Key Invalid" Error**:
   - Check if the API key is correctly set in `config.dart`
   - Ensure the YouTube Data API v3 is enabled in Google Cloud Console

2. **"Quota Exceeded" Error**:
   - You've reached your daily quota limit
   - Wait 24 hours or upgrade to a paid plan

3. **"No Results Found"**:
   - The search query might be too specific
   - Try broader search terms
   - Check your internet connection

4. **Images Not Loading**:
   - This is normal for YouTube thumbnails
   - The app will show placeholder icons

## API Endpoints Used

- **Search**: `https://www.googleapis.com/youtube/v3/search`
- **Video Details**: `https://www.googleapis.com/youtube/v3/videos`

## Security Notes

- Never commit your API key to version control
- Consider using environment variables for production
- Monitor your API usage in Google Cloud Console
- Set up billing alerts to avoid unexpected charges

## Support

If you encounter any issues:
1. Check the console logs for error messages
2. Verify your API key is correct
3. Ensure you have internet connectivity
4. Check your Google Cloud Console for quota usage
