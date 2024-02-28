# ciphy: human_directios v0

A project aimed to make googleMaps directions more readable, in order to enable the user to get anywhere without looking at any map.

This project uses openAI's chatgpt to translate the output from Google directions to a more humane instruction.

## Usage
This project is built in flutter and dart.

For the moment, this project is aimed to be on a mobile device, hence the main file structures the output in a screen in which all the data output is shown in a simple way.

to get the directions, after building the object of class HumanDirections (Which requires two api keys, GoogleDirections and openAI), it is needed to call the method fetchHumanDirections giving the origin and destination as arguments. Then you can access the data output through the members of the object class HumanDirections. But the main member is called humanDirectionsResult which contains the chatgpt output as a string.

### Example App
Using the app provided, it is possible to test the package just using the UI by providing an origin and destination in the corresponding text fields.
The preferred format for the inputs would be as full address, for example Champ de Mars, 5 Av. Anatole France, 75007 Paris, France (the Eiffel Tower address), however it also works with geo-coords, and partial addresses, however in the last case the results could be unexpected as the Google directions API will have to guess the missing parts.

## Requirements
### Api keys
the api keys must be in a file called '.env' inside the assets folder.
Then the variables for the keys need to be called:
OPENAI_API_KEY=key
GOOGLE_DIRECTIOS_API_KEY=key
### Dependencies.
dart_openai: ^5.1.0 : https://pub.dev/packages/dart_openai

google_directions_api: ^0.10.0 : https://pub.dev/packages/google_directions_api/example

flutter_dotenv: ^5.1.0 : https://pub.dev/packages/flutter_dotenv

http:  ^1.1.0
