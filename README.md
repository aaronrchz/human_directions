# ciphy: human_directios v0

Human directions is a package that tries to improve the instructions given by a GPS navigation system, using AI to re-organize said instructions to a more familiar vocabulary, understandable to almost anyone.

## Requirements

### Api keys 
This package needs two api keys to work, a Google cloud API key (enabled for directions API and places(new) API) and a OpenAI API key

### Dependencies.

dart_openai: ^5.1.0 : https://pub.dev/packages/dart_openai

google_directions_api: ^0.10.0 : https://pub.dev/packages/google_directions_api/example

flutter_dotenv: ^5.1.0 : https://pub.dev/packages/flutter_dotenv

geolocation: ^11.0.0 : https://pub.dev/packages/geolocator

http:  ^1.1.0


## Usage
This project is built in flutter and dart.
|
For the moment, this project is aimed to be on a mobile device, hence the main file structures the output in a screen in which all the data output is shown in a simple way.

to get the directions, after building the object of class HumanDirections (Which requires two api keys, GoogleDirections and openAI), it is needed to call the method fetchHumanDirections giving the origin and destination as arguments. Then you can access the data output through the members of the object class HumanDirections. But the main member is called humanDirectionsResult which contains the chatgpt output as a string.

### Features
There are two main features on this package:
The humanization of directions: the humanization is as described above, based on and origin and destination, the package outputs the directions, (the user can use its geolocation as the origin).

The recommendation of places: given an input as "where can i get a drink?" using the google_places API the AI will choose a set of places to recommend the user.

As for the showcase app, the recommendations output can be used to get the directions.

### Example App
Using the app provided (in example/showcase/app), it is possible to test the package just using the UI by providing an origin and destination in the corresponding text fields.
The preferred format for the inputs would be as full address, for example Champ de Mars, 5 Av. Anatole France, 75007 Paris, France (the Eiffel Tower address), however it also works with geo-coords, and partial addresses, however in the last case the results could be unexpected as the Google directions API will have to guess the missing parts.

#### How to use

First of all, it is needed to add the next line to the file 'AndroidManifest.xml'

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Then the example can be accessed as fallows


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
### Independet Examples

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
        "number": "the number odf the instruction", //int
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
        "number": "the number odf the instruction", //int
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