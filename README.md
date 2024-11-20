# denpasar-food
## Group members
- Derensh Pandian		
- Isaac Jesse Boentoro		
- Donia Sakji		
- Ferdinand Bonfilio Simamora		
- Adiena Nimeesha Adiwinastwan		
- Bryant Warrick Cai		

## Link to the APK (not required at Stage I. The APK link can be added to README.md after completing Stage II.)

Link : 

## Application description

Denpasar Restaurant Finder - Flutter Application

This Flutter-based mobile application enables users to discover and explore restaurants in the Denpasar area. It interfaces with a Django-based web backend to provide up-to-date restaurant information.

Features:

- Find Nearby Restaurants: Utilizes device location services to display restaurants close to the user's current position.
- Browse Restaurant Database: Offers access to a comprehensive database of restaurants in Denpasar.
- Sort and Filter Options: Allows users to sort and filter restaurants by criteria such as cuisine type, price range, and more.
- Restaurant Details: Provides detailed information about each restaurant, including menus, photos, operating hours, and contact information.
- "Restaurants Near Me" Feature: A dedicated function to list nearby dining options and view their locations on a map.

Technical Overview:

- Frontend: Developed with Flutter for a consistent user experience across Android and iOS platforms.
- Backend: Powered by a Django-based web application that manages restaurant data and handles user queries.

## List of modules to be implemented
```
restaurants
authentication
reviews
maps
admin_dashboard
navigation
```

## Integration with the web service to connect to the web application created in the midterm project

TODO: How each module interact with the web-service

## Roles or actors of the user application

Guest:
- Filter restaurants
- Read restaurants

Customer:
- Filter restaurants
- Read restaurants
- Comment on restaurants
- Leave reviews on restaurant

Admin:
- Add/modify/delete account data from the database
- Add/modify/delete restaurant data from the database


# Dev Notes
## Instruction for other user to start the code:

TODO: update the Dev Notes for the flutter version

NOTE: The following instructions ASSUME that your current local repo is fresh out of 
```
git clone https://github.com/K6-PBD-Midterm/denpasar_food_mobile.git
```

If you are in windows use `python`, if you're on linux/mac use `python3`

Make sure you are in the root folder when running startup code, for example:

```
for Windows
C:\Users\ferdi\OneDrive\Desktop\denpasar-food>

for Mac

```

Make sure you do the following startup code in order (except if told otherwise)

### Step 1:
Inside the root directory of this repository, run:
```
python -m venv env
```

### Step 2:
Activate the virtual environment by running:

Windows:
```
env\Scripts\activate
```

Unix (Mac/Linux):
```
source env/bin/activate
```

Note: On Windows, if you get an error that running scripts is disabled on your system, follow these steps:
1. Open Windows PowerShell as an administrator. (Search "PowerShell" on start menu, then right-click -> Run as administrator)
2. Run the following command: `Set-ExecutionPolicy Unrestricted -Force`

### Step 3: Install Tailwind

If you don't have node.js installed yet, you should install it first: see this tutorial for more information: [How to Install Node.js and NPM on Windows and Mac](https://radixweb.com/blog/installing-npm-and-nodejs-on-windows-and-mac#windows).

After that, run:
```
npm install -D tailwindcss
```

### Step 4:
Inside the virtual environment (with `(env)` indicated in the terminal input line), run:
```
pip install -r requirements.txt
```

### Step 5:
Run the following commands:
```
python manage.py makemigrations
python manage.py migrate
python manage.py load_restaurants
```

### Step 6:
Run the server by running the following command:
```
python manage.py runserver
```
