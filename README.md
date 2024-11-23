# grocy

A project for Group 2 in Mobile Applications (fall 2024) at NTNU Ålesund.

## Getting Started

## First Run
The project is configured with data from supabase (database) only.

```
flutter pub get
```

### Magic Links for the authentication redirect
#### For iOS and Android
In order for magic links to work on mobile devices, snip bits of code needs to be altered depending on your mobile device, here is a link that defaults to the iOS setup: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter?queryGroups=platform&platform=ios

#### For web
Magic links for web is set up  by using https://docs.flutter.dev/ui/navigation/url-strategies

## Build

### For Web
```
flutter build web
```
### For Android
```
flutter build apk
```
### For iOS
```
flutter build ios
```

## Run Configurations
### For chrome specifically
```
flutter run -d chrome
```

### To choose browser via terminal
```
flutter run
```

Alternatively use
```
flutter run --release
```

## Authentication
This application uses magic link authentication by Supabase. https://supabase.com/docs/guides/getting-started/tutorials/with-flutter

In order to use the app, you have to be authenticated. There is no guest functionality.

### How to use the authentication method

#### Web
When running it via IDE (either release or debug mode), in order to authenticate you have to either register user (if you don't have one) or sign in, when the link is sent you need to open the email (outlook.com) in the same browser that the app opened in, else the deep linking does not work. For testing purposes, Stig Arne is not registered in the database, so he will need to be registered before being able to get into the app. (Note, email may be instant, or it may take up to 5 minutes for it to be received).
- Note when running the app this way, session is not stored, and it will prompt you to log in every time. However, if run as an app (not in IDE), your session is stored.

#### Mobile
Disclaimer: We have only tested on Android

**Test Account is provided in inspera, to be used in both Outlook and Grocy**
**If not registered:**
  - Submit will send a link to sign up, where user receives an email from supabase to sign up. Where upon pressing the sign up link, the user is redirected to product item list, where they get a popup dialog window that prompts the user to choose a username. After choosing a username (and it is valid!) they are now directly in the product list.
**If registered:**
- Sign in will send a link to sign in, when the link in email is clicked, the user is sent directly to the product list screen (tabs).
<br>

# Features

## Barcode Scanning
- Scan a grocery item to see if it exists in grocy yet, if not user can add the product and choose which primary tag the product belongs to.

## Product List
- User can view all products in a list.
  - Each product has an image, title text and amount of reviews for the product.
  - **For Web users:** Due to CORS policies, some images may not load when using the web browser. Enjoy a selection of placeholder icons instead.
- In the search bar, the user can choose a primary tag or find a user created tag to filter products, for example say the user wants to find only energy drinks, they could filter by "Drinks" and if there is a user added tag of "energy drink" then it would only show products matching this criteria.
- User can search for a product specifically via the searchbar, such as "bu" or "urn" will match the product "Burn".

## Product Item Screen
In the product item screen, the user can do the following:
- View the overall review rating of the product.
- Leave a review, which takes user to a screen where they can choose which type of ratings and optional description of their review.
- Add product to wishlist via the heart icon.
- Add a user tag to a product, by linking it to an existing primary tag. Such as for example primary tag of "drink" and create  a user tag of "energy" or "energy drink", and then energy drink can be added to Burn.

## Wishlist
- Users can remove products that were previously added from the product item screen, and this will be updated in the database.

