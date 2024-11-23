# Grocy
A project for Group 2 in Mobile Applications (fall 2024) at NTNU Ålesund.

## Goal
Have you ever bought something at a grocery store, only to find out it wasn't what you thought you were buying? Or maybe you've noticed that your local brand of crisps has reduced the pack contents from 300g to 200g with the same price tag? Or maybe you just don't think something you've bought was worth the price?

Grocery producers get away with a lot more than other consumer products. If a laptop producer makes a laptop that runs poorly, the sales will drop as people leave reviews. However, if a bin of Greek Yoghurt Ice Cream barely contains greek yoghurt, few people ever speak up about it, and even fewer check what people say.

It is time to hold grocery producers responsible and place them under the same scrutiny that other producers need to endure, and raise their standards to focusing on quality, not just profitability and how many corners they can cut.

Grocy's mission is to hold grocery producers responsible by creating an open and efficient platform for the average Joe, like you and me, to host a network that helps consumers buy responsibly, happily, and to be ensured that they are paying for products made for consumers first, rather than profit. Our application allows consumers to quickly and effectively inform one another of whether they recommend a product or spite it. Join the community and help make grocery shopping a more satisfactory experience.

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
In order to authenticate you may register as a new user, or sign into an existing user. Upon doing either, a magic link will be sent to your e-mail account. For testing purposes, Stig Arne is not registered in the database, so he will need to be registered before being able to get into the app. **Note**: The email may be delayed anywhere between 1 to 10 minutes. If you don't receive the email in that time, retry the registration/sign-in process.

When running the app in development mode (i.e. from an IDE), sessions will not be saved, and you will have to redo the login process every time you start the app. You will also have to open the magic link from the browser in which the app is hosted. Otherwise, the link will be invalid.

#### Mobile
Disclaimer: The app has not been tested on iOS.

**Test Account is provided in inspera, to be used in both [Outlook](https://outlook.com) and Grocy**
**When creating an account:**
  - Submitting will send a link to sign up to the entered email, prompting to click a magic link in order to sign up. Upon pressing the sign up link, the user is redirected to the home screen. Since you are signing up, you will need to enter a username before proceeding to the app. After choosing a valid username they are now directly in the product list.
**When signing in:**
- Submitting will send a link to sign in to the entered email, prompting to click a magic link in order to sign in. The user is sent directly to the home screen.
<br>

# Features

## Barcode Scanning
The barcode scanner can be found on the left-most tab in the bottom navigation. Upon scanning a barcode in this screen, two things may happen:
1. The product has already been registered by someone else, and you will be taken directly to its review page.
2. The product has not been scanned yet, and you will be prompted to help set it up. You only have to give the product a primary tag, as the rest will be automatically filled in.

## Home screen
When in the home screen, the user can view all the products that are available.
  - Each product has an image, title text and amount of reviews for the product.
  - **For Web users:** Due to CORS policies, some images may not load when using the web browser. Enjoy a selection of placeholder icons instead.
- The user can search for a product by a primary tag or find a user created tag to filter products. For example say the user wants to find only energy drinks, they could filter by "Drinks". If there is a user added tag of "energy drink" then it would only show products matching this criteria.
- Users can search for a product by its name, by entering a search term into the search bar. Terms like "bu" or "urn" will match the product "Burn".

## Product Screen
In the product item screen, the user can do the following:
- View a summarized average rating of the product.
- Leave a rating. When leaving a rating, the user can freely choose which categories to leave a rating in, and optionally include a review. Any ratings that are untouched (indicated by the stars being empty and grey), will not contribute to the overall rating of the product.
- Add the product to wishlist via the heart icon.
- Add a user tag to a product. When adding tags to a product, you can only add tags that exist in the product's primary tag (the tag outlined in red on the product screen). For example, a Food product can be tagged with "burger", but not with "battery".

## Wishlist
The wishlist provides quick access to products you have selected. This quick access can be used to check reviews on products, or to keep track of new products you want to try.
- Users can remove products form their wishlist by pressing the heart button either on the wishlist screen or in the product screen.

