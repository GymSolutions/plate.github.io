# plate.

GitHub Pages-ready demo of plate., a responsive meal and nutrition tracker.

## Included
- First-launch setup with light/dark mode, goals, likes, dislikes, and dietary notes.
- Dashboard with daily meal totals.
- Local food-library search with common foods and editable servings.
- Manual natural-language meal entry using the local food library.
- Photo upload/camera flow that creates an editable draft without sending the image anywhere.
- Meal history.
- Local browser storage; no account or paid API required.
- Responsive mobile + desktop layout.

## Food data architecture
The demo ships with a compact local food library so it works immediately on GitHub Pages without an API key. The UI and data shape are ready to replace/extend the local library with USDA FoodData Central. USDA provides both an API and downloadable datasets; see https://fdc.nal.usda.gov/.

## GitHub Pages
Open `index.html` as the site root or upload the contents of this folder to a GitHub repository and enable GitHub Pages from the repository's Pages settings.

## Important
Nutrition estimates are informational and can be inaccurate. The app intentionally lets the user edit food, serving, and nutrition values before saving. The photo flow is a local demo placeholder for a future free/local vision model; it does not claim to identify food automatically yet.
