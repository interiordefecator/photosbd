# photosbd

A small bash utility intended to help photographers organize their images by date taken (using ImageMagick to read EXIF data).

Usage:
```photosbd [-y|-m|-d] [target_dir]```

Sorting specificity:
  ```
  -y  #by year only (example: mytarget/2025/*.jpg)
  -m  #(default) by year then month: (example: mytarget/2025/03/*.jpg)
  -d  #by year, then month, then day: (example: mytarget/2025/03/08/*.jpg)
```

If no output target is specified, current directory will be used.
