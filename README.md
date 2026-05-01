# ComfyEssentials
A singular macOS utility for the stuff that should just work. no bloat,
just the tools you actually reach for every day.

# Features

## Text Normalization
you copy something and it comes with a mess of: 
- stray spaces
- weird line breaks 
- and invisible garbage characters

Text Normalization handles it automatically the moment you paste.
- Paste text (normalization runs instantly)
- Clean text is copied to your clipboard
- Close the window and focus your next app


## Selection OCR
- Vertical text
- rotated labels
- text inside images

anything you can see but can't select (or u can just hard to copy). 
-  Draw a region
- take a screenshot
- get the extracted text back immediately

From there you can clean it up however you need.

# Dependencies

- ComfyWindowKit
  - Window Management Library extracted out of [ComfyTile](https://github.com/AryanRogye/ComfyTile)
  - This uses private API's. If that's a dealbreaker, this app isn't for you.

- [SnapCore](https://github.com/AryanRogye/SnapCore)
  - Powers the screenshot capture used by Selection OCR.
