# Emoji-D - List Processor

Utility for translating Unicode Emoji HTML lists to D enums.


## Usage

1. Download the [emoji list](https://unicode.org/emoji/charts/full-emoji-list.html)
2. `dub -- full-emoji-list.html emoji.d`
3. Verify the result: `rdmd --main emoji.d`


## FAQ

### Why translate HTML instead of the definition files?
It turned out to be easier.
