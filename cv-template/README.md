# 📄 CV Template - Based on Piotr Skwarna's Design

## 🎯 Overview

This is a clean, professional CV template extracted from [spidero/cv](https://github.com/spidero/cv) and customized for DevOps/Infrastructure engineers.

## 🏗️ Structure

```
cv-template/
├── my-cv.html          # Your personalized CV (EDIT THIS!)
├── index.html          # Original template (reference)
├── files/
│   ├── css/
│   │   └── custom.css  # Custom styling
│   ├── skeleton/       # Skeleton CSS framework
│   ├── fontawesome/    # Icons
│   └── images/         # Images (add your photo here)
└── README.md           # This file
```

## ✏️ How to Customize

### 1. Edit `my-cv.html`

Replace the placeholder information with your own:

- **Name and tagline** (lines 48-49)
- **Social links** (lines 58-60): LinkedIn, GitHub, Email
- **Professional Skills** (lines 66-110): Add your technologies and tools
- **Projects** (lines 119-135): Showcase your work
- **Experience** (lines 145-170): Add your work history
- **Certifications** (lines 180-187): List your credentials
- **Interests** (lines 195-197): Personal interests

### 2. Add Your Photo (Optional)

If you want a background image in the hero section:

1. Add your photo to `files/images/me.png`
2. Edit `files/css/custom.css` line 2:
   ```css
   background-image: url('/files/images/me.png');
   ```
   Replace the gradient with the image URL.

### 3. Customize Colors

Edit `files/css/custom.css` to change the color scheme:
- Primary color: `#667eea` (purple-blue)
- Secondary color: `#764ba2` (purple)

## 🚀 How to View

### Option 1: Simple HTTP Server (Python)

```bash
cd cv-template
python3 -m http.server 8000
```

Then open: http://localhost:8000/my-cv.html

### Option 2: Docker

Create a `Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

Build and run:

```bash
docker build -t my-cv .
docker run -d -p 8080:80 my-cv
```

Then open: http://localhost:8080/my-cv.html

### Option 3: Just open the file

Simply double-click `my-cv.html` in your file browser!

## 🎨 Features

- ✅ Responsive design (mobile-friendly)
- ✅ Clean, professional layout
- ✅ FontAwesome icons
- ✅ Skeleton CSS framework (lightweight)
- ✅ Easy to customize
- ✅ No build process required

## 📦 Technologies Used

- **HTML5** - Structure
- **CSS3** - Styling
- **Skeleton CSS** - Responsive grid framework
- **FontAwesome 6** - Icons
- **Google Fonts (Raleway)** - Typography

## 🙏 Credits

Original design by [Piotr Skwarna](https://github.com/spidero/cv)

## 📝 License

Feel free to use this template for your own CV!

---

**Happy job hunting! 🎯**
