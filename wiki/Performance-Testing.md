# Performance Testing with sitespeed.io

To ensure your WordPress site is running at peak performance, you can use **sitespeed.io**, a powerful tool for analyzing your website's speed and performance.

## 🐳 Running with Docker

The easiest way to run sitespeed.io is using Docker. This avoids needing to install local dependencies.

Run the following command in your terminal (replacing `https://your-domain.com/` with your actual site URL):

```bash
docker run --rm -v "$(pwd):/sitespeed.io" sitespeedio/sitespeed.io:39.4.2 https://your-domain.com/
```

### What this command does:
- `--rm`: Automatically removes the container after the test finishes.
- `-v "$(pwd):/sitespeed.io"`: Mounts your current directory into the container so the test reports are saved locally.
- `sitespeedio/sitespeed.io:39.4.2`: Uses the specific version of the sitespeed.io image.
- `https://your-domain.com/`: The URL of the site you want to test.

## 📊 Viewing the Results
Once the test completes, a new folder named `sitespeed-result` will be created in your current directory. 

Open the `index.html` file inside that folder in your browser to view a comprehensive report on:
- **Core Web Vitals** (LCP, FID, CLS)
- **Coach Advice**: Suggestions on how to improve performance.
- **Visual Metrics**: Screenshots and video of the page load.
- **Request Analysis**: Detailed breakdown of every asset loaded.

## 💡 Pro Tip
Since this stack is powered by **OpenLiteSpeed** and **Brotli**, you should see excellent performance scores out of the box!
