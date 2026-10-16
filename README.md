<h1 align="center">Verox</h1>
<h3 align="center">Translations for Verox's web interface</h3>
<br/>

Verox is a multi-protocol audio streaming OS for Raspberry Pi devices. It can be seen as an appliance, and as such requires no computer knowledge whatsoever. Its functionality is often called a 'network bridge'.

> This repo is the translation source for Verox's webpage. It's a rebrand of RoPieee's `ropieee-l10n`.

## Introduction

Verox's web interface supports multiple languages. This project contains the JSON files with 'all' text elements. The English translation (en-US) acts as the 'master' file: it is both the default language and the fallback used when a specific translation is missing a key.

## How does it work?

A translation file has keys, subkeys and values. The keys are used by the software to identify a specific text and should *not* be changed in any way.
So for example, in this snippet:

```
"MENU": {
        "SYSTEM": "System",
```

MENU is the key, SYSTEM is the subkey and "System" is the value (the actual text). So in this example, only the value "System" can be changed.

In some strings you will see something like this:

```
Welcome to {{.constants.GLOBAL_PROD_NAME}}
```

The text between double brackets (```{{..}}```) refers to a variable that the software will inject during displaying. Do *not* change these in any way.

When loading a page of Verox's web interface, the software looks up the text using the key and subkey. If it can't find the text, it falls back to its default (English from the en-US.json file).

When new texts are added (for example, because of a new feature), the corresponding entries are added to the master file. The [TODO](TODO.md) file will show what's missing (if any) in the other translation files.

When the meaning of an existing English text changes, that text is removed from the other translation files, so it shows up in the [TODO](TODO.md) file again and needs a new translation. Small wording changes that keep the meaning don't affect existing translations.

## Add translation

Adding a new translation can be done by opening a PR and introducing a new language file. That's the simple explanation 😅

A PR can also be used to propose changes to already existing files.

Before a PR can (potentially) be accepted, make sure the file is a valid JSON file. And if you're running on Linux, you can use a simple shell script, called `check.sh`, to check the validity and file contents.
When everything looks good, the PR might be accepted.

To summarize, keep this in mind when contributing:
- only one language (change) per PR
- make sure the JSON file is valid
- make sure you don't introduce unknown keys

The language files are shipped with the binary, so only an update to Verox itself can 'enable' a new language or publish changes.

Finally, there's the [TODO](TODO.md) file that shows (possible) remaining items to be translated per file.
