# Weather App

A simple Weather App that uses data from **Open Weather API** - <a>https://openweathermap.org</a>

### Please visit openwathermap and get your free api key and change demoApiKey in lib -> repository -> weather.dart

---

## Screenshots

## Home

- Click Current location(Coimbatore in my case) to refresh data.
- Click City icon to get data by searching city name.
- Scroll horizontally to view more forecasted data.

<br/>

<img src="screenshots/home.png" alt="Home" width="300"/>

## Search

<img src="screenshots/search.png" alt="Home" width="300"/>

## Search Suggestion

Search Suggestion is shown for hardcoded popular locations and input

<img src="screenshots/search_suggestion.png" alt="Home" width="300"/>

## Search Result

<img src="screenshots/weather_result.png" alt="Home" width="300"/>

---

## Features supported

<p>✅ &nbsp Fetch <strong>Weather Report for Current Location</strong></p>
<p>✅ &nbsp Fetch Weather <strong>Forecast Report for next 5 days</strong> for Current Location.</p>
<p>✅ &nbsp Fetch <strong>Weather Report for City Name</strong> entered in Search page.</p>
<p>✅ &nbsp Fetch <strong>Weather Forecast Report for next 5 days for City Name</strong> entered in Search page.</p>
<p>✅ &nbsp <strong>Offline storage</strong> for all the above features. <i> All you need is fetch data atleast once, before you go offline.</i></p>
<p>✅ &nbsp If switched from <strong>Offline to Online, data is synced automatically</strong></p>

<br/>
<b>What about tests?</b>
<p>✅ &nbsp Since business logics are written in Flutter Bloc, Added Bloc test. Bloc test for online mode works</p>
<p>[x] &nbsp Bloc test for offline mode will be added soon</p>
