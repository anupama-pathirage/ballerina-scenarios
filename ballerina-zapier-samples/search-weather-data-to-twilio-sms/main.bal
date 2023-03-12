import ballerina/http;
import ballerinax/twilio;

configurable string openweatherToken = ?;
configurable string lat = ?;
configurable string lon = ?;

configurable string twilioAccountSid = ?;
configurable string twilioAuthToken = ?;
configurable string twilioFrom = ?;
configurable string twilioTo = ?;

type Main record {
    decimal temp_max;
};

type Wind record {
    decimal speed;
};

type WeatherItem record {
    Main main;
    Wind wind;
    string dt_txt;
};

type City record {
    string name;
    string country;
};

type WeatherResponse record {
    WeatherItem[] list;
    City city;
};

type WeatherForecast record {
    string city;
    string country;
    string date;
    decimal max_temp;
    decimal wind_speed;
};

decimal threasholdTemp = 75;
decimal threasholdWind = 10;

public function main() returns error? {

    http:Client httpClient = check new ("https://api.openweathermap.org");
    WeatherResponse response = check httpClient->get(
        string `/data/2.5/forecast?lat=${lat}&lon=${lon}&units=imperial&appid=${openweatherToken}`);

    WeatherForecast[] alertedWeather = from var {main, wind, dt_txt} in response?.list
        where main.temp_max > threasholdTemp && wind.speed > threasholdWind
        order by main.temp_max descending
        select {
            city: response.city.name,
            country: response.city.country,
            date: dt_txt,
            max_temp: main.temp_max,
            wind_speed: wind.speed
        };

    twilio:Client twilioClient = check new ({
        twilioAuth: {
            accountSId: twilioAccountSid,
            authToken: twilioAuthToken
        }
    });
    _ = check twilioClient->sendSms(twilioFrom, twilioTo, transform(alertedWeather));
}

function transform(WeatherForecast[] alertedWeather) returns string {
    if alertedWeather.length() == 0 {
        return "No weather alerts";
    }
    string msgBody = string `Weather Alert:${alertedWeather[0].city},${alertedWeather[0].country}${"\n"}`;
    foreach var {date, max_temp, wind_speed} in alertedWeather {
        msgBody += string `${date} - T:${max_temp}|W:${wind_speed}${"\n"}`;
    }
    return msgBody;
}
