# Maintaining this tap

Everything happens on the GitHub website. No Terminal or git commands are needed
for routine updates.

## The idea in one paragraph

The formula (`Formula/hbmame.rb`) is a recipe: where to download HBMAME's source, its
checksum, and how to build it. A **bottle** is the finished, pre-compiled result for one
macOS version. GitHub builds the bottles whenever a **pull request** changes the recipe.
When the build is green, the **publish** step uploads the bottles to a GitHub Release and
writes their checksums into the recipe. From then on, `brew install` downloads the
bottle instead of compiling.

## The three workflows

| Workflow (Actions tab) | What it does | When it runs |
|---|---|---|
| **Bump HBMAME** | Updates the recipe to a new upstream tag and prepares a branch | You start it by hand |
| **brew test-bot** | Builds and tests HBMAME on macOS 15 and macOS 26, keeps the bottles | Automatically on every pull request |
| **brew pr-pull** | Uploads the bottles, updates the recipe, merges the pull request | When you add the label `pr-pull` |

## Updating to a new HBMAME version (e.g. `tag2895`)

1. **Bump.** Actions tab, **Bump HBMAME**, **Run workflow**, enter `tag2895`, **Run**.
   After about a minute it finishes. Its summary page shows a link to open the pull request.
2. **Open the pull request.** Click that link (or the yellow *Compare & pull request*
   banner on the repository's front page), then **Create pull request**.
3. **Wait for the build.** The pull request shows two checks running (macOS 15 and
   macOS 26). A full build takes a few hours. You can close the browser.
4. **Publish.** When both checks are green, open the **Labels** setting on the right
   side of the pull request and choose `pr-pull`. The publish workflow uploads the
   bottles and closes the pull request as merged. Then click **Delete branch**.

If a check fails, open it in the Actions tab to read the log. The pull request can be
closed without harm; nothing reaches users until step 4.

## Changing the recipe itself

Same flow, but instead of step 1 edit the file on a new branch. Either:

- **On github.com:** open `Formula/hbmame.rb`, click the pencil icon, edit, then
  *Commit changes...* and choose **Create a new branch for this commit and start a
  pull request**. Continue at step 3.
- **With GitHub Desktop:** *Current Branch*, *New Branch*, edit the file, *Commit*,
  *Publish branch*, then *Create Pull Request*. Continue at step 3.

## Testing a change locally before publishing (optional)

```sh
brew tap estefan3112/hbmame
brew install --build-from-source estefan3112/hbmame/hbmame
brew test estefan3112/hbmame/hbmame
brew audit --strict estefan3112/hbmame/hbmame
```

`brew tap` makes a local copy of this repository under
`$(brew --repository)/Library/Taps/estefan3112/homebrew-hbmame`. To test edits there,
open that folder in GitHub Desktop (*File*, *Add Local Repository*).
