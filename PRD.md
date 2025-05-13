Product Requirements Document (PRD)
App Name: Cuisines
Created: May 13, 2025
Owner: Michael Baxter

1. Purpose
The Cuisines App is a cross-platform app designed to help users explore global cuisines through the food they cook. As users try dishes from different regions, a globe visual highlights their culinary journey. The MVP focuses on personal food discovery, with social elements planned for later.

2. Target Users
Food enthusiasts interested in global cuisine

Home cooks wanting to track what they’ve tried

Users exploring food as part of travel or education

Future: food-sharing communities, restaurant promoters

3. Core MVP Features
✅ User Authentication
Sign up / Login

Basic user profile

✅ Cuisine & Recipe Browsing
Explore cuisines from a world map

View and search recipes by region or name

✅ “Want to Make” Tracking
Save recipes to a personal "Want to Make" list

Mark recipes as "Tried"

Progress: “X of Y” tried within a cuisine

✅ World Map Integration
Regions light up based on user activity

Tap regions to explore relevant recipes

✅ Data Seeding
Initial population of cuisines and recipes via API or manual import

4. Stretch Goals
Meal sharing and social feed

Restaurant discovery and reviews

Friend/follow system

Restaurant promotion tools

5. Technical Stack
Frontend
Framework: Flutter

Navigation: Bottom tab bar (mobile), sidebar (desktop)

State Management: Provider, Riverpod, or Bloc

Maps: flutter_map, google_maps_flutter, or web-based globe.gl

Backend
Platform: Xano

Auth: Xano built-in

API: RESTful via Xano

Optional Data Source: Spoonacular, TheMealDB, etc.

6. Data Models (MVP)
Users
id, email, name

Cuisines
id, name, description, region

Recipes
id, name, cuisine_id, ingredients, instructions, image

Ingredients
id, name

UserWantToMakeRecipes
user_id, recipe_id, cuisine_id, status (Want to Make / Made), added_date

7. Key Screens
Cuisines Tab
Globe view

List of cuisines with progress

Recipes Tab
Searchable recipe list

Save to “Want to Make”

Profile Tab
Show saved/tried recipes

Summary of cuisine progress

8. Roadmap
Phase 1
Flutter project setup ✅

GitHub integration ✅

Folder structure ✅

Phase 2
Auth

Cuisines & Recipes screens

Want to Make tracking

Map integration

Phase 3
API integration

Basic profile view

Phase 4
Social and community features

9. Success Metrics
Recipes saved and completed

Regions explored

Active return users

Social engagement (in future phases)

10. Notes
UI/UX is based on mockups for both mobile and desktop.

Built with flexibility for future growth (especially community features).

</content>