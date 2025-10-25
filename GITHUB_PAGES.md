# GitHub Pages Configuration

This repository is configured to serve the landing page via GitHub Pages.

## 🌐 Live URL

Once configured, your landing page will be available at:
```
https://YOUR-USERNAME.github.io/Brandy/
```

## 📁 Structure

The landing page is served from the `docs/` folder:
```
docs/
├── index.html       ← Landing page
└── README.md        ← Documentation
```

## ⚙️ Setup Instructions

### Step 1: Enable GitHub Pages

1. Go to your repository on GitHub: `https://github.com/YOUR-USERNAME/Brandy`
2. Click **Settings** (gear icon)
3. Scroll down to **Pages** section (left sidebar)
4. Under **Source**, select:
   - **Branch**: `claude/brand-name-generator-011CUJxLC4TtTSd55nyc7SWX` (or `main`)
   - **Folder**: `/docs`
5. Click **Save**

### Step 2: Wait for Deployment

- GitHub will automatically build and deploy your site
- This usually takes 1-2 minutes
- You'll see a green checkmark when it's ready

### Step 3: Access Your Site

Visit: `https://YOUR-USERNAME.github.io/Brandy/`

## 🔄 Automatic Deployments

Every time you push changes to the `docs/` folder, GitHub Pages will automatically rebuild your site.

## 🛠️ Custom Domain (Optional)

To use a custom domain (e.g., `brandy.pe`):

1. Add a file named `CNAME` to the `docs/` folder:
   ```
   brandy.pe
   ```

2. Configure DNS records with your domain provider:
   ```
   Type: CNAME
   Name: www
   Value: YOUR-USERNAME.github.io

   Type: A (for apex domain)
   Name: @
   Value: 185.199.108.153
   Value: 185.199.109.153
   Value: 185.199.110.153
   Value: 185.199.111.153
   ```

3. In GitHub Settings → Pages → Custom domain, enter: `brandy.pe`

4. Enable "Enforce HTTPS"

## 🧪 Local Testing

Test the site locally before pushing:

```bash
cd docs
python3 -m http.server 8080
# Visit: http://localhost:8080
```

## 📝 Making Changes

1. Edit `docs/index.html`
2. Test locally
3. Commit and push:
   ```bash
   git add docs/
   git commit -m "Update landing page"
   git push
   ```
4. Wait 1-2 minutes for GitHub Pages to rebuild

## 🔧 Troubleshooting

### Site not loading?
- Check that GitHub Pages is enabled in Settings
- Verify the branch and folder are correct
- Wait 2-3 minutes after pushing

### 404 Error?
- Ensure `index.html` exists in `docs/` folder
- Check file name capitalization (must be lowercase)
- Clear browser cache

### Changes not appearing?
- Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)
- Wait a few minutes for deployment
- Check Actions tab for build status

## 📊 Analytics (Optional)

Add Google Analytics to track visitors:

1. Get your GA4 tracking ID
2. Add to `docs/index.html` in the `<head>`:
   ```html
   <!-- Google Analytics -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
   <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag('js', new Date());
     gtag('config', 'G-XXXXXXXXXX');
   </script>
   ```

## 🚀 Alternative: GitHub Actions Deployment

For more control, use GitHub Actions (already configured in `.github/workflows/deploy.yml`).

## 📞 Support

If you need help:
- GitHub Pages Documentation: https://docs.github.com/pages
- Check repository Actions tab for deployment logs
- Verify branch and folder settings

---

**Your landing page is ready to go live!** 🎉
