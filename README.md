# ciphy: human_directios v0

Human directions is a package that tries to **improve the instructions given by a GPS navigation system, using AI to re-organize said instructions to a more familiar vocabulary**, understandable to almost anyone.

## Requirements

### Api keys 
This package needs **two api keys to work**, a Google cloud API key (enabled for directions API and places(new) API) and a OpenAI API key

### Dependencies.

dart_openai: ^5.1.0 : https://pub.dev/packages/dart_openai

google_directions_api: ^0.10.0 : https://pub.dev/packages/google_directions_api/example

flutter_dotenv: ^5.1.0 : https://pub.dev/packages/flutter_dotenv

geolocation: ^11.0.0 : https://pub.dev/packages/geolocator

http:  ^1.1.0


## Usage

**First of all, it is needed to add the next line to the file 'AndroidManifest.xml'**

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

This project is built in** flutter and dart**.

to get the directions, after building the object of class ```HumanDirections``` (**Which requires two api keys, GoogleDirections and openAI**), it is needed to call the method fetchHumanDirections giving the origin and destination as arguments. Then you can access the data output through the members of the object class HumanDirections. But the main member is called ```humanDirectionsResult``` which contains the chatgpt output as a ```string```.

### HumanDirections class

Main class for the human directions package.

**This class provides functionality for fetching human directions based on specified origin and destination, as well as handling nearby places recommendations and current location retrieval**.

#### Parameters:

##### Required:

- **openAiApiKey**: (```String```) OpenAI API key to access the AI model.

- **googleDirectionsApiKey**: (```String```) Google Cloud key with access to Directions and Places (new) API to fetch directions and places recommendations.

##### Optional:

- **googlelanguage**: (```String, Default value: 'en'```) the chosen language code for the Google Directions output you can find all the languages at https://developers.google.com/maps/faq#languagesupport **However, it is strongly recommended to keep the language as English, as this does not affect 'human directions' and all the system messages for the AI are in English**
    
- **unitSystem**: (```google_direction_api package UnitSystem, Default value: UnitSystem.metric```) the unit system used for Direction API to measure the distances and to give the instructions.
    
- **openAIlanguage**: (```String, Default value: OpenAILanguage.en```) the language in which the AI will communicate with the user there's a class that's part of this package that contains all the supported languages to March 13, 2024: ```package:human_directions/components/llm/supported_languages.dart```

- **placesRadius**: (```double, Default value: 50.0```) this value represents the dimension of the radius to fetch places for the directions, as they are used to better give better references for each step, this does not affect the recommendations, as that radius is chosen by the AI

- **gptModel**: (```String, Default value: OpenAiModelsNames.gpt4```) this is the name of the used AI model, there's a class that contains all the model names up to March 13, 2024: ```package:human_directions/components/llm/models.dart``` however, as for previous tests, GPT-4 is considered to be the best fit.
   
- **gptModelTemperature**: (```double, Default value: 0.4```) temperature is a number between 0 and 2, when set higher the outputs will be more random and possibly imprecise, closer to 0 the outputs will be more deterministic

#### Output Data:

- **resolvedDistance**: (```Distance```) The calculated distance between origin and destination after executing the methods fetchHumanDirections or fetchHumanDirectionsFromLocation, if none of those methods are executed successfully the members text and value are null.

- **resolvedTime**: (```Time```): The calculated estimated time to go between origin and destination after executing the methods fetchHumanDirections or fetchHumanDirectionsFromLocation, if none of those methods are executed successfully the members text and value are null.

- **steps**: (```List<Step> type from package:google_directions_api```) a list with each instruction step given by Direction API.
  
- **requestResult**: (```String,  Default value 'awaiting'```) the result from the request to Directions API.

- **humanDirectionsResult**: (```String?```) the string resulting from fetchHumanDirections or fetchHumanDirectionsFromLocation, this is a JSON Map with the next format:
 ```
{
  "start_message": "any message to give context for the user before giving the instructions",
  "steps": "a list with each converted instruction as a map" [{
      "number": "the number of the instruction", //int
      "instruction": "the converted instruction",
    }],
  "end_message": "any context closing message for the user"
}
 ```
- **nearbyPlacesFrom**: (```List<String>```) the collection of nearby places relative to the start location of each step from direction API.

- **nearbyPlacesTo**: (```List<String>```) the collection of nearby places relative to the end location of each step from direction API.

- **currentPosition**: (```GeoCoord type from package:google_directions_api```): the user's current position, value null until the execution of getCurrentLocation, fetchHumanDirectionsFromLocation or fetchHumanDirections.

- **lastException**: (```String?```) last exception given from any called method from this class.

### Features
There are two main features on this package:
**The humanization of directions**: the humanization is as described above, based on and origin and destination, the package outputs the directions, (the user can use its geolocation as the origin).

**The recommendation of places**: given an input as "where can i get a drink?" using the google_places API the AI will choose a set of places to recommend the user.

As for the **showcase app**, the recommendations output can be used to get the directions.

### Example App
Using the **app provided** (in ```package:human_directions/example/showcase/app```), it is possible to **test the package** just using the UI by providing an origin and destination in the corresponding text fields.
The **preferred** format for the inputs would be as **full address**, for example Champ de Mars, 5 Av. Anatole France, 75007 Paris, France (the Eiffel Tower address), however it **also works** with **geo-coords**, and partial addresses, however in the last case the results could be unexpected as the Google directions API will have to guess the missing parts.

### Independet Examples

#### Showcase app

The example app can be accessed as fallows


```
import 'package:flutter/material.dart';
import 'package:human_directions/example/showcase_app/human_directions_app.dart';

void main() {
  final String openAiApiKey = 'YOUR_API_KEY';
  final String googleDirectionsApiKey = 'YOUR_API_KEY';

  runApp(HumanDirectionsApp(
    googleDirectionsApiKey: googleDirectionsApiKey,
    openAiApiKey: openAiApiKey,
  ));
}

```


#### Get Origin-Destination based Directions

```
/*This is a simplified example of how to use the the human_directions package, however the controller 
has more parameters that can change the output, such as the lenguage */

import 'package:human_directions/human_directions.dart';
import 'package:human_directions/components/llm/steps_parse.dart';

void getHumanDirectionsExample() async {
  const String openAiApiKey = 'YOUR_API_KEY';
  const String googleDirectionsApiKey = 'YOUR_API_KEY';
  final HumanDirections controller = HumanDirections(
      openAiApiKey: openAiApiKey,
      googleDirectionsApiKey: googleDirectionsApiKey);
  const String origin = '2220 Louisiana Blvd NE, Albuquerque, NM 87110';
  //or
  // const String origin = '35.10306238493775, -106.56850233266698';
  const String destination = '601 Eubank Blvd SE, Albuquerque, NM 87123';
  //or
  // const String destination = '35.066128531595254, -106.533857392472'

  int directionsFlag =
      await controller.fetchHumanDirections(origin, destination);
  if (directionsFlag == 0) {
    print(controller
        .directionsStepsList); //contains a list with all the googleDirections Api Steps (and placesApi nearby places for each step)
    print(controller
        .humanDirectionsResult); //this contains a string that's formatted as a map
    /*Map format:
    {
      "start_message": "any message to give context for the user before giving the instructions",
      "steps":"a list with each converted instruction as a map"[{
        "number": "the number of the instruction", //int
        "instruction": "the converted instruction",
      }],
      "end_message": "any context closing message for the user"
    } 
    the package contains a parse class that can decode the result to a more usable object*/
    HumanDirectionsOutput output =
        HumanDirectionsOutput.fromString(controller.humanDirectionsResult!);
    print(output.startMessage);
    for (var step in output.steps) {
      print('${step.number} - ${step.instruction}');
    }
    print(output.endMessage);
  }
}


```

#### Get Current Location to Destination based Directions

```
import 'package:human_directions/human_directions.dart';
import 'package:human_directions/components/llm/steps_parse.dart';

/*This is a simplified example of how to use the the human_directions package, however the controller 
has more parameters that can change the output, such as the lenguage */
void getHumanDirectionsFromLocationExample(BuildContext context) async {
  const String openAiApiKey = 'YOUR_API_KEY';
  const String googleDirectionsApiKey = 'YOUR_API_KEY';
  final HumanDirections controller = HumanDirections(
      openAiApiKey: openAiApiKey,
      googleDirectionsApiKey: googleDirectionsApiKey);

  const String destination = '601 Eubank Blvd SE, Albuquerque, NM 87123';
  //or
  // const String destination = '35.066128531595254, -106.533857392472'

  int directionsFlag =
      await controller.fetchHumanDirectionsFromLocation(destination, context);
  //context is required as the GeoLocation package needs to check if there's permission to use the location
  if (directionsFlag == 0) {
    print(controller
        .directionsStepsList); //contains a list with all the googleDirections Api Steps (and placesApi nearby places for each step)
    print(controller
        .humanDirectionsResult); //this contains a string that's formatted as a map
    /*Map format:
    {
      "start_message": "any message to give context for the user before giving the instructions",
      "steps":"a list with each converted instruction as a map"[{
        "number": "the number of the instruction", //int
        "instruction": "the converted instruction",
      }],
      "end_message": "any context closing message for the user"
    } 
    the package contains a parse class that can decode the result to a more usable object*/
    HumanDirectionsOutput output =
        HumanDirectionsOutput.fromString(controller.humanDirectionsResult!);
    print(output.startMessage);
    for (var step in output.steps) {
      print('${step.number} - ${step.instruction}');
    }
    print(output.endMessage);
  }
}

```

#### Get recommendatios for nearby places.

```
import 'package:human_directions/human_directions.dart';
import 'package:human_directions/components/llm/recomendations_parse.dart';

/*This is a simplified example of how to use the the human_directions package, however the controller 
has more parameters that can change the output, such as the lenguage */
void getNearbyPlacesRecommendations(BuildContext context) async {
  const String openAiApiKey = 'YOUR_API_KEY';
  const String googleDirectionsApiKey = 'YOUR_API_KEY';
  final HumanDirections controller = HumanDirections(
      openAiApiKey: openAiApiKey,
      googleDirectionsApiKey: googleDirectionsApiKey);
  const String prompt = 'Where can i get a drink?';

  NearbyPlacesRecomendationsObject recommendations =
      await controller.getNearbyRecommendations(prompt, context);

  if (recommendations.hasError) {
    print(recommendations.errorMessage);
    return;
  }
  int c = 0;
  print(recommendations.startMessage);
  for (var recommendation in recommendations.recommendations!) {
    print(recommendation.name);
    print(recommendation.address);
    print(recommendation.description);
    print(recommendation.openingHours);
    print(recommendation.rating);
    print(recommendation.phoneNumber);
    print(recommendations.recomendationPhotos!.placePhotoUriCollection[c]
        ['uri_collection'][0]); //gets the first photo uri for the place
  }
  print(recommendations.closingMessage);
}

```