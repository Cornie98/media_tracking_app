# RAWG API Setup Guide

## What is RAWG API?
RAWG is a free video game database API that provides comprehensive information about games across all platforms (PC, console, mobile).

## Getting Your API Key

1. **Visit RAWG Website**: Go to https://rawg.io/
2. **Create Account**: Sign up for a free account
3. **Get API Key**: 
   - Go to your profile settings
   - Navigate to the API section
   - Generate a new API key
4. **Free Tier Limits**: 
   - 20,000 requests per month
   - More than enough for personal use

## Adding to Your App

1. **Add to .env file**:
   ```
   RAWG_API_KEY=your_api_key_here
   ```

2. **Features Available**:
   - Search games by title
   - Get game details, release dates, platforms
   - High-quality game artwork
   - Game ratings and reviews
   - Platform information (PC, PS5, Xbox, Switch, etc.)

## API Endpoints Used

- **Search Games**: `GET /api/games?key={api_key}&search={query}&page_size=20`
- **Game Details**: `GET /api/games/{id}?key={api_key}`

## Game Data Structure

Each game includes:
- `id`: Unique game identifier
- `name`: Game title
- `released`: Release date
- `background_image`: Game cover art
- `rating`: Average rating
- `platforms`: Available platforms

## Color Scheme for Games

- **Icon**: 🎮 `Icons.sports_esports`
- **Color**: Indigo (`Colors.indigo`)
- **Calendar Symbol**: Purple circle with game controller icon

## Testing

After adding your API key to the .env file, you can:
1. Go to the Log page
2. Select "Game" as the media type
3. Search for any game (e.g., "Minecraft", "GTA", "Zelda")
4. The app will fetch game data from RAWG API

## Troubleshooting

- **API Key Error**: Make sure your RAWG_API_KEY is correctly set in the .env file
- **No Results**: Check your internet connection and API key validity
- **Rate Limiting**: Free tier allows 20,000 requests/month, which should be sufficient

## Popular Game Examples to Test

- Minecraft
- Grand Theft Auto V
- The Legend of Zelda: Breath of the Wild
- Red Dead Redemption 2
- Cyberpunk 2077
- Elden Ring
- God of War
- The Witcher 3 